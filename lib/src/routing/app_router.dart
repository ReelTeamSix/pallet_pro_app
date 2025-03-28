import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/biometric_auth_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/biometric_setup_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide UserSettings;
import 'package:pallet_pro_app/src/core/utils/responsive_utils.dart';

/// The router provider.
// Use Provider instead of NotifierProvider for simpler router instance creation
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: !kReleaseMode, // Only log in debug mode
    refreshListenable: notifier,
    redirect: notifier._redirectLogic,
    routes: notifier._routes,
    // Track navigation events to update current path without causing circular deps
    observers: [
      RouteObserver(),
      // Custom observer to track current route
      notifier._routeObserver,
    ],
  );
});

/// Provider for the router notifier logic.
final routerNotifierProvider =
    NotifierProvider<RouterNotifier, void>(RouterNotifier.new);

/// Manages routing logic and triggers refreshes based on auth/settings state.
class RouterNotifier extends Notifier<void> implements Listenable {
  VoidCallback? _routerListener;
  bool _isBiometricAuthShowing = false;
  bool _wasResumed = false;
  bool _isNotifying = false;
  bool _isOnSettingsScreen = false;
  DateTime _lastNotification = DateTime.now();
  // Add a timestamp to track when app started
  final DateTime _appStartTime = DateTime.now();
  // Maximum time to wait on splash screen (3 seconds)
  static const Duration _maxSplashWaitTime = Duration(seconds: 3);
  // Timer to force periodic checks for splash timeout
  Timer? _splashTimeoutTimer;

  // Create a route observer to track current screen
  final _routeObserver = _RouterObserver();
  
  @override
  void build() {
    // Add callback to update settings screen flag
    _routeObserver.onRouteChanged = (String path) {
      _isOnSettingsScreen = path == '/settings';
      debugPrint('RouterNotifier: Route changed to $path, isOnSettingsScreen: $_isOnSettingsScreen');
    };
    
    // Listen to both auth and user settings providers.
    // When either changes significantly (loading state, error, data presence),
    // notify the GoRouter to re-evaluate the redirect.
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      _handleProviderChange(previous, next, 'AuthController');
    });

    ref.listen<AsyncValue<UserSettings?>>(userSettingsControllerProvider, (previous, next) {
      _handleProviderChange(previous, next, 'UserSettingsController');
    });
    
    // Set up a timer to periodically check if we've been on the splash screen too long
    // This ensures we don't get stuck even if no state changes occur
    _splashTimeoutTimer?.cancel();
    _splashTimeoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final timeOnSplash = DateTime.now().difference(_appStartTime);
      if (timeOnSplash > _maxSplashWaitTime) {
        debugPrint('RouterNotifier: Splash timeout check - forcing redirect after ${timeOnSplash.inSeconds} seconds');
        _debouncedNotifyListeners();
        _splashTimeoutTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _splashTimeoutTimer?.cancel();
  }

  /// Helper to determine if a provider state change warrants a router refresh.
  void _handleProviderChange<T>(AsyncValue<T>? previous, AsyncValue<T> next, String providerName) {
    // Only notify if the loading status, error status, or data presence changes.
    // This prevents unnecessary refreshes during background data updates.
    final wasLoading = previous is AsyncLoading;
    final isLoading = next is AsyncLoading;
    final hadError = previous is AsyncError;
    final hasError = next is AsyncError;
    final hadValue = previous?.hasValue ?? false;
    final hasValue = next.hasValue;
    
    // Check for sign-out event specifically (user was present, now null)
    final isSignOutEvent = providerName == 'AuthController' && 
                          previous is AsyncData<User?> && 
                          next is AsyncData<User?> && 
                          (previous as AsyncData<User?>).value != null && 
                          (next as AsyncData<User?>).value == null;
    
    if (isSignOutEvent) {
      // Sign-out deserves immediate notification regardless of debounce
      debugPrint('RouterNotifier: Sign-out detected, immediately notifying');
      _lastNotification = DateTime.now();
      // Force immediate redirect on sign-out without debouncing
      Future.microtask(() {
        debugPrint('RouterNotifier: Force immediate redirect for sign-out');
        notifyListeners(); 
      });
      return;
    }

    // Ignore UserSettings changes if within settings context - use a cached location value
    // rather than trying to access router (which causes circular dependency)
    if (providerName == 'UserSettingsController') {
      // Store path based on router lifecycle events rather than reading router directly
      // If this is a settings update and we're on the settings screen, don't trigger a refresh
      if (_isOnSettingsScreen) {
        debugPrint('RouterNotifier: Ignoring UserSettings change while on settings screen');
        return;
      }
    }

    if (isLoading != wasLoading || hasError != hadError || hasValue != hadValue) {
      debugPrint('RouterNotifier: $providerName changed significantly, considering refresh.');
      
      // Debounce notifications to prevent rapid-fire redirects
      final now = DateTime.now();
      final timeSinceLastNotification = now.difference(_lastNotification);
      
      if (timeSinceLastNotification < const Duration(milliseconds: 100)) {
        debugPrint('RouterNotifier: Skipping notification, too soon after last one (${timeSinceLastNotification.inMilliseconds}ms)');
        return;
      }
      
      _debouncedNotifyListeners();
    }
  }
  
  /// Debounces notifications to avoid excessive redirects
  void _debouncedNotifyListeners() {
    if (_isNotifying) {
      return;
    }
    
    _isNotifying = true;
    _lastNotification = DateTime.now();
    
    // Use Future.microtask to ensure we don't trigger during build
    Future.microtask(() {
      debugPrint('RouterNotifier: Notifying listeners.');
      notifyListeners();
      _isNotifying = false;
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _routerListener = listener;
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_routerListener == listener) {
      _routerListener = null;
    }
  }

  @override
  void notifyListeners() {
    if (_routerListener != null) {
      try {
        _routerListener!.call();
      } catch (e) {
        debugPrint('RouterNotifier: Error during listener notification: $e');
      }
    }
  }

  /// Called when the app is resumed.
  void appResumed() {
     if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        _wasResumed = true;
        debugPrint('RouterNotifier: App Resumed, notifying.');
        _debouncedNotifyListeners(); // Use debounced method
     }
  }

  /// Resets the resume flag after biometric check.
  void resetResumeFlag() {
    _wasResumed = false;
  }
  
  /// Context-free method to check if we're on splash screen and navigate if needed
  void checkAndNavigateFromSplash() {
    // Get router instance
    final router = ref.read(routerProvider);
    
    // Check current location without using BuildContext
    final location = router.routeInformationProvider.value.uri.path;
    
    if (location == '/splash') {
      debugPrint('RouterNotifier: Forcing navigation from splash to login via safety timer');
      router.go('/login?from=safety_timer');
    } else {
      debugPrint('RouterNotifier: Safety timer fired but not on splash screen (current: $location)');
    }
  }

  /// The routes for the application.
  List<RouteBase> get _routes => [
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashScreen(),
            // Add a fade transition for smoother experience
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            // Use longer duration for initial splash but shorter for transitions away from it
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: LoginScreen(from: state.uri.queryParameters['from']),
            // Add a fade transition for smoother experience
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            // Use shorter duration for better responsiveness
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => SignupScreen(
            // Pass the 'from' parameter to know the source of navigation
            from: state.uri.queryParameters['from'],
          ),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/biometric-setup',
          name: 'biometric-setup',
          builder: (context, state) => const BiometricSetupScreen(),
        ),
        GoRoute(
          path: '/biometric-auth',
          name: 'biometric-auth',
          builder: (context, state) => BiometricAuthScreen(
            // Reset resume flag when navigating away from biometric auth
            onAuthenticated: () => resetResumeFlag(),
            onCancel: () => resetResumeFlag(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const InventoryScreen(),
                // Add a fade transition for smoother experience when coming from login/splash
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                // Use shorter duration for better responsiveness
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const SettingsScreen(),
                // Add a fade transition for smoother experience
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                // Use shorter duration for better responsiveness
                transitionDuration: const Duration(milliseconds: 250),
              ),
            ),
            // Add more routes here as needed
          ],
        ),
      ];

  /// The core redirect logic. Watches auth and settings state.
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final queryParams = state.uri.queryParameters;
    debugPrint('RouterNotifier: Redirect check triggered for location: $location, params: $queryParams');

    try {
      // Snapshot providers ONCE at the beginning to avoid "Cannot use ref functions after dependency changed" errors
      final authActionState = ref.read(authControllerProvider);
      final rawAuthState = ref.read(authStateChangesProvider);
      final settingsState = ref.read(userSettingsControllerProvider);
      
      final isSplash = location == '/splash';
      final isLoginRoute = location == '/login' || location == '/signup';
      final from = queryParams['from'] ?? '';

      // --- 1. Handle VERY Initial Raw Auth Load ---
      // Stay on splash ONLY while the raw auth state stream is initially loading.
      final isRawAuthLoading = !rawAuthState.hasValue && !rawAuthState.hasError;
      
      // Calculate how long we've been waiting for auth to initialize
      final splashWaitedTooLong = DateTime.now().difference(_appStartTime) > _maxSplashWaitTime;
      
      // Prevent redirect loops with special safety timer case
      if (from == 'safety_timer' && isLoginRoute) {
        debugPrint('RouterNotifier: Safety timer initiated navigation to login. Allowing.');
        return null;
      }
      
      if (splashWaitedTooLong && isSplash) {
        // After waiting too long on splash, always go to login regardless of auth state
        debugPrint('RouterNotifier: Auth initialization timeout after ${_maxSplashWaitTime.inSeconds} seconds. Forcing redirect to login.');
        return '/login?from=timeout';
      }
      
      if (isRawAuthLoading) {
        debugPrint('RouterNotifier: Raw Auth loading. Staying on splash.');
        // Stay on splash or force back if somehow navigated away during this brief initial load
        return isSplash ? null : '/splash';
      }

      // --- 2. Handle Raw Auth Error ---
      final rawAuthError = rawAuthState.error;
      if (rawAuthError != null) {
         debugPrint('RouterNotifier: Raw Auth Error: $rawAuthError. Redirecting to /login.');
         // Redirect to login on initial auth error
         return (isLoginRoute) ? null : '/login';
      }

      // --- 3. Handle Auth Action Loading ---
      // Check for auth action in progress without creating dependency on state changing
      final isAuthActionLoading = authActionState is AsyncLoading;
      
      // Explicitly check if we've already applied a splash redirect to prevent loops
      final isComingFromTimeout = from == 'timeout';
      final isComingFromAuthAction = from == 'auth_action';
      
      // Avoid redirect loops by improving origin/destination checks
      if (isAuthActionLoading && isLoginRoute && !isComingFromAuthAction && !isComingFromTimeout) {
          debugPrint('RouterNotifier: Auth action in progress from login/signup. Redirecting to splash.');
          return '/splash?from=auth_action';
      }
      
      // If we're already on splash due to auth action, don't redirect again
      if (isSplash && isComingFromAuthAction && isAuthActionLoading) {
          debugPrint('RouterNotifier: Already on splash for auth action. Staying.');
          return null;
      }
      
      // If we're on login from timeout, don't redirect even for auth action
      if (isLoginRoute && isComingFromTimeout && isAuthActionLoading) {
          debugPrint('RouterNotifier: On login from timeout during auth action. Staying.');
          return null;
      }

      // --- 4. Raw Auth Resolved, No Explicit Action Loading ---
      final user = rawAuthState.value?.session?.user;
      final isLoggedIn = user != null;

      // --- 4a. Not Logged In ---
      if (!isLoggedIn) {
        debugPrint('RouterNotifier: Raw Auth resolved: Not logged in. Redirecting to /login.');
        // Go directly to login unless already on login/signup routes
        return (isLoginRoute) ? null : '/login?from=not_logged_in';
      }

      // --- 4b. Logged In (User confirmed via Raw Auth) ---
      // Now check settings state specifically for logged-in users.
      debugPrint('RouterNotifier: Raw Auth resolved: Logged In as ${user.id}. Checking settings...');

      final isSettingsLoading = !settingsState.hasValue && !settingsState.hasError;
      final settingsError = settingsState.error;

      // Only show splash WHILE settings are first loading AFTER user is confirmed.
      // Use query parameter to avoid redirect loops
      final isComingFromSettingsLoading = from == 'settings_loading';
      final isLoadingSettings = isSettingsLoading && !isComingFromSettingsLoading;
      
      if (isLoadingSettings) {
          debugPrint('RouterNotifier: Settings initially loading for logged-in user. Forcing to splash.');
          return isSplash ? null : '/splash?from=settings_loading';
      }
      
      // Don't redirect again if we're already at splash waiting for settings
      if (isSplash && isComingFromSettingsLoading && isSettingsLoading) {
          debugPrint('RouterNotifier: Already at splash waiting for settings. Staying.');
          return null;
      }

      // Handle settings error for logged-in user
      if (settingsError != null) {
           debugPrint('RouterNotifier: Settings Error for logged-in user: $settingsError. Redirecting to /login.');
           // Fallback to login on settings error
           return (isLoginRoute) ? null : '/login';
      }

      // --- 5. Logged In, Settings Loaded Successfully ---
      final userSettings = settingsState.value;
      
      // Check if settings are null but there's no error - this is a race condition where
      // settings haven't been fetched yet after login but auth is confirmed
      if (userSettings == null) {
         // If we're already on splash or auth screens, stay there rather than creating a loop
         if (isSplash || isLoginRoute) {
           debugPrint('RouterNotifier: Settings not yet available, but on appropriate waiting screen.');
           return null;
         }
         debugPrint('RouterNotifier: Logged in, settings not yet available. Redirecting to /splash.');
         return '/splash?from=waiting_settings';
      }

      debugPrint('RouterNotifier: Logged in, settings loaded. Onboarding: ${userSettings.hasCompletedOnboarding}.');

      // Define route checks (needed for subsequent logic)
      final isOnboardingRoute = location == '/onboarding';
      final isBiometricAuthRoute = location == '/biometric-auth';
      final isBiometricSetupRoute = location == '/biometric-setup';
      final isHomeRoute = location == '/home';

      // --- Biometric Check on App Resume --- (Keep existing logic)
      final isOnProtectedLocation = !isLoginRoute && !isOnboardingRoute && !isBiometricSetupRoute && !isBiometricAuthRoute && !isSplash;
       if (_wasResumed && (userSettings.useBiometricAuth ?? false) && isOnProtectedLocation && !_isBiometricAuthShowing) {
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
             debugPrint('RouterNotifier: App resumed, biometric enabled, on protected route. Redirecting to /biometric-auth.');
             _isBiometricAuthShowing = true; // Prevent re-entry loops
             WidgetsBinding.instance.addPostFrameCallback((_) {
                 _isBiometricAuthShowing = false;
             });
             return '/biometric-auth';
          } else {
             _wasResumed = false; // Reset flag on web/desktop
          }
       }
       if (location != '/biometric-auth') {
           resetResumeFlag();
       }

      // --- Onboarding Check ---
      if (!(userSettings.hasCompletedOnboarding ?? false)) { // Handle null safety
        debugPrint('RouterNotifier: Needs onboarding.');
        return isOnboardingRoute ? null : '/onboarding';
      }

      // --- Post-Onboarding/Login Redirects ---
      // Redirect away from auth/splash/onboarding screens if fully logged in and onboarded
      if (isLoginRoute || isOnboardingRoute || isSplash) {
          final needsBiometricSetup = !(userSettings.useBiometricAuth ?? true) // Default true if null
                                      && !isBiometricSetupRoute
                                      && !kIsWeb && (Platform.isAndroid || Platform.isIOS);

          if (needsBiometricSetup && isOnboardingRoute) { // Redirect from onboarding only
               debugPrint('RouterNotifier: Onboarding complete, needs biometric setup. Redirecting to /biometric-setup.');
               return '/biometric-setup';
          } else {
               // Add a query parameter to indicate a smooth transition to avoid flashing
               debugPrint('RouterNotifier: Logged in and onboarded. Redirecting away from $location to /home.');
               return '/home?from=auth_complete'; 
          }
      }

      // Redirect away from biometric setup if already done or not applicable
      if (isBiometricSetupRoute && ((userSettings.useBiometricAuth ?? false) || kIsWeb || (!Platform.isAndroid && !Platform.isIOS))) {
          debugPrint('RouterNotifier: On biometric setup but already setup/not applicable. Redirecting to /home.');
          return '/home';
      }

      // --- Default Case ---
      // All checks passed, user is logged in, onboarded, settings loaded, no special condition applies.
      debugPrint('RouterNotifier: All checks passed for $location. Allowing navigation.');
      return null; // No redirect needed, stay on the current target route.
    } catch (e, stack) {
      debugPrint('RouterNotifier: Error in redirect logic: $e\n$stack');
      
      // In case of an unexpected error, try to stay on the current route
      // or go to login as a fallback, to prevent infinite redirect loops
      final location = state.matchedLocation;
      if (location == '/login' || location == '/signup') {
        return null; // Stay on login/signup route if already there
      } else if (location == '/home') {
        return null; // Stay on home if already there
      } else {
        return '/login?from=error_recovery'; // Use login as a safe fallback
      }
    }
  }

  /// Checks if biometric auth should be shown based on settings and platform.
  /// NOTE: This logic seems duplicated/implicitly handled by the main redirect. Keeping for reference or potential future use.
  // bool _shouldShowBiometricAuth(UserSettings settings) {
  //   return _wasResumed &&
  //          settings.useBiometricAuth &&
  //          !kIsWeb &&
  //          (Platform.isAndroid || Platform.isIOS);
  // }
}

/// The app shell, providing consistent navigation (Drawer or BottomNav).
class AppShell extends ConsumerWidget {
  /// Creates a new [AppShell] instance.
  const AppShell({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  // Helper function to calculate navigation index based on route
  int _calculateSelectedIndex(String currentLocation) {
    if (currentLocation.startsWith('/settings')) {
      return 1;
    }
    // Default to Inventory/Home
    return 0;
  }

  // Helper for navigation logic
  void _navigate(BuildContext scaffoldContext, int index, String currentLocation) {
     bool drawerIsOpen = Scaffold.of(scaffoldContext).isDrawerOpen;
     if (drawerIsOpen) {
      Navigator.of(scaffoldContext).pop();
    }

    // Use Future.delayed to allow the drawer to close before navigating
    Future.delayed(drawerIsOpen ? const Duration(milliseconds: 50) : Duration.zero, () {
      if (!scaffoldContext.mounted) return;
      
      if (index == 0 && !currentLocation.startsWith('/home')) {
        GoRouter.of(scaffoldContext).go('/home');
      } else if (index == 1 && !currentLocation.startsWith('/settings')) {
        GoRouter.of(scaffoldContext).go('/settings');
      }
    });
  }
  
  // Helper for sign out logic
  Future<void> _signOut(BuildContext scaffoldContext, WidgetRef ref) async {
     try {
        // Close drawer if open before attempting to sign out
        if (Scaffold.of(scaffoldContext).isDrawerOpen) {
          Navigator.of(scaffoldContext).pop();
          // Add a slight delay to ensure the drawer has closed
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        // Check if context is still valid after drawer close
        if (!scaffoldContext.mounted) return;
        
        // Show loading indicator to prevent multiple taps
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(
            content: Text('Signing out...'),
            duration: Duration(seconds: 1),
          ),
        );
        
        // Force trigger notifyListeners on the router after sign-out completes
        ref.read(authControllerProvider.notifier).signOut().then((_) {
          // Force a router refresh if the redirect didn't happen automatically
          ref.read(routerNotifierProvider.notifier)._debouncedNotifyListeners();
        });
        
        // Router redirect will automatically handle navigation to login
      } catch (e) {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            SnackBar(
              content: Text(
                e is AppException
                    ? e.message
                    : 'Failed to sign out: ${e.toString()}'
              ),
              backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
            ),
          );
        }
      }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _calculateSelectedIndex(currentLocation);

    // Determine layout based on platform/screen size
    final bool useDrawerLayout = ResponsiveUtils.isDesktop(context) || ResponsiveUtils.isTablet(context);

    if (useDrawerLayout) {
      // Web/Desktop/Tablet Layout using Drawer
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pallet Pro'),
          // Drawer icon will be added automatically by Scaffold
        ),
        drawer: Drawer(
          child: Builder(
            // Use Builder to get context below the Scaffold for Drawer
            builder: (drawerContext) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(drawerContext).colorScheme.primaryContainer,
                    ),
                    // TODO: Add nice header content? Logo? App name?
                    child: Text(
                      'Pallet Pro',
                      style: Theme.of(drawerContext).textTheme.titleLarge?.copyWith(
                        color: Theme.of(drawerContext).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Inventory'),
                    selected: selectedIndex == 0,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 0, currentLocation),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    selected: selectedIndex == 1,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 1, currentLocation),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    // Use the drawerContext for ScaffoldMessenger
                    onTap: () => _signOut(drawerContext, ref),
                  ),
                ],
              );
            }
          ),
        ),
        body: child, // Main content area
      );
    } else {
      // Mobile Layout using BottomNavigationBar
      return Scaffold(
        // Use Builder to get context below the Scaffold for sign-out SnackBar
        body: Builder(
          builder: (scaffoldBodyContext) { 
            return Column(
              children: [
                AppBar(
                  title: const Text('Pallet Pro'),
                  // No back button automatically if it's a top-level route in Shell
                  // Add leading drawer button explicitly if needed, but maybe not typical for BNV
                  actions: [
                    // Settings button - only on mobile if not on settings screen
                    if (selectedIndex != 1)
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Settings',
                        // Use scaffoldBodyContext for navigation
                        onPressed: () => _navigate(scaffoldBodyContext, 1, currentLocation), 
                      ),
                    // Logout button - keep on AppBar for mobile?
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Sign Out',
                      // Use scaffoldBodyContext for ScaffoldMessenger
                      onPressed: () => _signOut(scaffoldBodyContext, ref),
                    ),
                  ],
                ),
                Expanded(child: child), // Main content takes remaining space
              ],
            );
          }
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          // Use context from Builder above for navigation
          onTap: (index) => _navigate(context, index, currentLocation),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      );
    }
  }
}

/// Placeholder for SplashScreen - Replace with your actual splash screen if you have one.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon could go here
              const Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              Text(
                'Pallet Pro',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ensure BiometricAuthScreen accepts callbacks
class BiometricAuthScreen extends StatelessWidget {
  final VoidCallback? onAuthenticated;
  final VoidCallback? onCancel;

  const BiometricAuthScreen({super.key, this.onAuthenticated, this.onCancel});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual Biometric Auth UI
    // Call onAuthenticated on success, onCancel on failure/user cancel
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please authenticate to continue.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Simulate successful authentication
                await Future.delayed(const Duration(seconds: 1));
                debugPrint("BiometricAuthScreen: Authenticated (simulated)");
                onAuthenticated?.call();
                // Typically, GoRouter's refresh will handle navigation
                // after the state change caused by successful auth.
                // If not, you might need manual navigation:
                // if (context.canPop()) context.pop(); else context.go('/home');
              },
              child: const Text('Authenticate (Simulate)'),
            ),
             ElevatedButton(
              onPressed: () {
                 debugPrint("BiometricAuthScreen: Cancelled");
                 onCancel?.call();
                 // Navigate back or to login on cancel
                 context.go('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom route observer to track navigation events without circular dependencies.
class _RouterObserver extends NavigatorObserver {
  /// Callback to notify when routes change
  Function(String path)? onRouteChanged;
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateCurrentRoute(route);
    super.didPush(route, previousRoute);
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _updateCurrentRoute(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _updateCurrentRoute(previousRoute);
    }
    super.didPop(route, previousRoute);
  }
  
  void _updateCurrentRoute(Route<dynamic> route) {
    // Extract path from route
    final String? path = _extractPathFromRoute(route);
    
    if (path != null && onRouteChanged != null) {
      onRouteChanged!(path);
    }
  }
  
  String? _extractPathFromRoute(Route<dynamic> route) {
    // Try to extract GoRoute path
    if (route.settings.name != null) {
      return route.settings.name;
    }
    
    // For go_router pages, extract from RouteMatchList if possible
    final settings = route.settings;
    if (settings is Page) {
      final key = settings.key;
      if (key is ValueKey<String> && key.value.startsWith('/')) {
        return key.value;
      }
    }
    
    // Fallback to settings.name which might be null
    return route.settings.name;
  }
}
