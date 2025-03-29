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
import 'package:pallet_pro_app/src/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/pin_auth_screen.dart';
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
  bool _wasResumed = false;
  bool _isNotifying = false;
  bool _isOnSettingsScreen = false;
  // Flag to track if the *initial* authentication check after login has passed.
  bool _initialAuthDone = false; 
  DateTime _lastNotification = DateTime.now();
  final DateTime _appStartTime = DateTime.now();
  // Timestamp for the last successful authentication (initial or resume)
  DateTime? _lastAuthCompletionTime; 
  static const Duration _authCooldownDuration = Duration(seconds: 1);
  static const Duration _maxSplashWaitTime = Duration(seconds: 3);
  Timer? _splashTimeoutTimer;
  final _routeObserver = _RouterObserver();
  
  @override
  void build() {
    // _initialAuthDone should persist until logout, so don't reset it here.
    
    _routeObserver.onRouteChanged = (String path) {
      _isOnSettingsScreen = path == '/settings';
      debugPrint('RouterNotifier: Route changed to $path, isOnSettingsScreen: $_isOnSettingsScreen');
    };
    
    // Listen for sign-out events to reset the initial auth flag.
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      final userJustSignedOut = previous?.hasValue == true && previous?.value != null && 
                                next?.hasValue == true && next?.value == null;
      if (userJustSignedOut) {
        debugPrint('RouterNotifier: User signed out, resetting _initialAuthDone.');
        _initialAuthDone = false;
      }
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
        // Ignore resume events that happen immediately after auth completion
        final now = DateTime.now();
        if (_lastAuthCompletionTime != null && 
            now.difference(_lastAuthCompletionTime!) < _authCooldownDuration) {
          debugPrint('RouterNotifier: App Resumed within cooldown period, ignoring.');
          return;
        }

        _wasResumed = true;
        debugPrint('RouterNotifier: App Resumed, notifying.');
        _debouncedNotifyListeners();
     }
  }

  /// Marks the initial authentication check as completed successfully.
  /// Called by auth screens (PIN/Biometric) upon successful verification.
  void markInitialAuthCompleted() {
    debugPrint('RouterNotifier: Initial authentication marked as completed.');
    _initialAuthDone = true;
    _lastAuthCompletionTime = DateTime.now(); // Record completion time
    // Also reset the resume flag to prevent redirect loops
    _wasResumed = false;
    debugPrint('RouterNotifier: Also reset resume flag to prevent redirect loops.');
    // No need to notify here, the navigation triggered by the auth screen 
    // will cause the redirect logic to run again.
  }

  /// Called when an auth prompt triggered by app resume is explicitly cancelled.
  void cancelResumeCheck() {
    debugPrint('RouterNotifier: Resume check explicitly cancelled by user.');
    _wasResumed = false;
    // No need to notify here, the navigation from cancel action will trigger _redirectLogic
  }

  /// The core redirect logic.
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final queryParams = state.uri.queryParameters;
    // Define from and reason early for use throughout the function
    final from = queryParams['from'] ?? '';
    final reason = queryParams['reason'] ?? ''; 
    
    debugPrint(
        'RouterNotifier: Redirect check | Location: $location | Params: $queryParams | Reason: $reason | From: $from | InitialAuthDone: $_initialAuthDone | WasResumed: $_wasResumed');

    try {
      // Snapshot providers
      final authActionState = ref.read(authControllerProvider);
      final rawAuthState = ref.read(authStateChangesProvider);
      final settingsState = ref.read(userSettingsControllerProvider);
      
      final isSplash = location == '/splash';
      final isLoginRoute = location == '/login' || location == '/signup';

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
        // If already on login/signup, or just arrived from cancel/fail, stay there.
        if (location == '/login' || location == '/signup') {
          if (from == 'cancel' || from == 'fail') {
             debugPrint('RouterNotifier: On login/signup from cancel/fail. Staying.');
             _initialAuthDone = false; // Ensure we reset this flag when on login from cancel
             return null; // Explicitly stay on login
          }
          debugPrint('RouterNotifier: Not logged in, but already on login/signup. Staying.');
          _initialAuthDone = false; // Ensure flag is reset
          return null;
        }
        // Otherwise, redirect to login
        debugPrint('RouterNotifier: Not logged in. Resetting flags and redirecting to /login.');
        _initialAuthDone = false;
        _wasResumed = false; // Reset resume flag on logout/redirect to login
        return '/login?from=not_logged_in';
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

      debugPrint('RouterNotifier: Logged In & Settings Loaded | Onboarding: ${userSettings.hasCompletedOnboarding} | Biometric: ${userSettings.useBiometricAuth} | PIN: ${userSettings.usePinAuth} | InitialAuth: $_initialAuthDone');

      // Define route checks
      final isOnboardingRoute = location == '/onboarding';
      final isBiometricAuthRoute = location == '/biometric-auth';
      final isBiometricSetupRoute = location == '/biometric-setup';
      final isPinAuthRoute = location == '/pin-auth';
      final isPinSetupRoute = location == '/pin-setup';
      final isHomeRoute = location == '/home';

      final isAuthRelatedRoute = location == '/login' || location == '/signup' || 
                                 location == '/onboarding' || 
                                 isBiometricAuthRoute || 
                                 location == '/biometric-setup' || 
                                 isPinAuthRoute || 
                                 location == '/pin-setup' || 
                                 location == '/splash';

      final isOnProtectedLocation = !isAuthRelatedRoute;

      // --- Initial App Launch Authentication Check (Runs only if logged in and initial auth not done) ---
      if (!_initialAuthDone && isOnProtectedLocation) {
         String? authRoute;
         bool needsInitialAuth = false;
         if (userSettings.useBiometricAuth && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            authRoute = '/biometric-auth';
            needsInitialAuth = true;
            debugPrint('RouterNotifier: Initial Launch Check: Needs Biometric.');
         } else if (userSettings.usePinAuth) {
            authRoute = '/pin-auth';
            needsInitialAuth = true;
            debugPrint('RouterNotifier: Initial Launch Check: Needs PIN.');
         }

         if (needsInitialAuth && authRoute != null) {
            // Prevent redirect loop if already on the target auth route
            if (location != authRoute) {
               // Add reason parameter
               debugPrint('RouterNotifier: Redirecting to initial auth route: $authRoute?reason=initial_auth');
               return '$authRoute?reason=initial_auth'; 
            }
            // Already on the correct auth route, stay put
            debugPrint('RouterNotifier: Already on initial auth route $authRoute. Staying.');
            return null; // Added return null
            
         } else {
            // No initial auth required (e.g., neither enabled)
            debugPrint('RouterNotifier: Initial Launch Check: No auth needed. Marking done.');
            _initialAuthDone = true; // Mark as done if no check is needed
         }
      }

      // --- App Resume Authentication Check (Runs only if logged in and app was resumed) ---
      if (_wasResumed && isOnProtectedLocation) {
         // Reset resume flag immediately to prevent re-triggering this block
         debugPrint('RouterNotifier: Handling app resume.');
         _wasResumed = false; 

         String? resumeAuthRoute;
         bool needsResumeAuth = false;
          if (userSettings.useBiometricAuth && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            resumeAuthRoute = '/biometric-auth';
            needsResumeAuth = true;
            debugPrint('RouterNotifier: Resume Check: Needs Biometric.');
         } else if (userSettings.usePinAuth) {
            resumeAuthRoute = '/pin-auth';
            needsResumeAuth = true;
            debugPrint('RouterNotifier: Resume Check: Needs PIN.');
         }

         if (needsResumeAuth && resumeAuthRoute != null) {
            // Prevent redirect loop if already on the target auth route
            if (location != resumeAuthRoute) {
              // Add reason parameter
               debugPrint('RouterNotifier: Redirecting to resume auth route: $resumeAuthRoute?reason=resume_auth');
               return '$resumeAuthRoute?reason=resume_auth';
            }
            // Already on the correct auth route, stay put
            debugPrint('RouterNotifier: Already on resume auth route $resumeAuthRoute. Staying.');
            return null; // Added return null

         } else {
             // No resume auth needed, flag already reset above.
             debugPrint('RouterNotifier: Resume Check: No auth needed.');
         }
      }

      // --- Onboarding Check ---
      if (!(userSettings.hasCompletedOnboarding ?? false)) {
        debugPrint('RouterNotifier: Needs onboarding.');
        // Redirect away from PIN setup during onboarding
        if (isPinSetupRoute) return '/onboarding'; 
        return isOnboardingRoute ? null : '/onboarding';
      }

      // --- Post-Onboarding/Login Redirects ---
      // If fully authenticated and onboarded, redirect away from auth/splash/onboarding
      if (isLoginRoute || isOnboardingRoute || isSplash) {
          final bool canUseBiometrics = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
          // Redirect to Biometric setup if needed (only from onboarding)
          final bool needsBiometricSetup = canUseBiometrics 
                                          && !(userSettings.useBiometricAuth ?? false)
                                          && !isBiometricSetupRoute;

          if (needsBiometricSetup && isOnboardingRoute) { 
               debugPrint('RouterNotifier: Onboarding complete, needs biometric setup. Redirecting to /biometric-setup.');
               return '/biometric-setup';
          } 
          // TODO: Consider adding PIN setup redirect here? 
          // E.g., if biometrics skipped/unavailable, prompt for PIN?
          // For now, just go home.
          else {
               debugPrint('RouterNotifier: Logged in and onboarded. Redirecting away from $location to /home.');
               return '/home?from=auth_complete'; 
          }
      }

      // Redirect away from biometric setup if already done or not applicable
      if (isBiometricSetupRoute && ((userSettings.useBiometricAuth ?? false) || kIsWeb || (!Platform.isAndroid && !Platform.isIOS))) {
          debugPrint('RouterNotifier: On biometric setup but already setup/not applicable. Redirecting to /home.');
          return '/home';
      }
      
      // Redirect away from PIN setup if PIN auth is disabled (user might land here via deep link)
      if (isPinSetupRoute && !userSettings.usePinAuth && (userSettings.pinHash != null && userSettings.pinHash!.isNotEmpty)) {
         debugPrint('RouterNotifier: On PIN setup but PIN auth is disabled. Redirecting to /settings.');
         return '/settings'; // Or /home?
      }

      // --- Final Check: Properly Handle Authentication Conflicts ---
      // 'from' and 'reason' are already defined above

      // Special case: Allow direct navigation from biometric to PIN auth
      if (isPinAuthRoute && from == 'biometric') { // Use 'from' here if needed
          debugPrint('RouterNotifier: Allowing direct navigation from biometric to PIN auth');
          return null; // Let the navigation to PIN auth proceed
      }
      
      // Check if we are on an auth route specifically because it was required (using 'reason')
      final bool onRequiredAuthRoute = (isPinAuthRoute || isBiometricAuthRoute) &&
                                       (reason == 'initial_auth' || reason == 'resume_auth');

      // If initial auth is done and user is logged in, redirect away from auth screens
      // UNLESS the user was just sent there for a required auth check.
      if (_initialAuthDone && isLoggedIn && (isPinAuthRoute || isBiometricAuthRoute) && !onRequiredAuthRoute) {
         debugPrint('RouterNotifier: Already authenticated & not required, redirecting from $location to /home'); // Updated msg
         return '/home';
      }
      
      // If we are on login/signup but actually logged in and initial auth is done, go home
      if (_initialAuthDone && isLoggedIn && (location == '/login' || location == '/signup')) {
          debugPrint('RouterNotifier: Logged in and initial auth done, redirecting from login/signup to /home');
          return '/home';
      }
      
      // --- Default Case --- 
      debugPrint('RouterNotifier: All checks passed for $location. Allowing navigation.');
      return null; 
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

  /// The routes for the application.
  List<RouteBase> get _routes => [
        GoRoute(
          path: '/splash',
          name: 'splash',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: LoginScreen(from: state.uri.queryParameters['from']),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => SignupScreen(
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
            // Pass the reason from query parameters
            reason: state.uri.queryParameters['reason'],
          ),
        ),
        GoRoute(
          path: '/pin-setup',
          name: 'pin-setup',
          builder: (context, state) => const PinSetupScreen(),
        ),
        GoRoute(
          path: '/pin-auth',
          name: 'pin-auth',
          builder: (context, state) => PinAuthScreen(
            // Pass the reason from query parameters
            reason: state.uri.queryParameters['reason'],
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
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
            GoRoute(
              path: '/scan',
              name: 'scan',
              builder: (context, state) => const PlaceholderScreen(title: 'Scan/Add'),
            ),
            GoRoute(
              path: '/sales',
              name: 'sales',
              builder: (context, state) => const PlaceholderScreen(title: 'Sales'),
            ),
            GoRoute(
              path: '/analytics',
              name: 'analytics',
              builder: (context, state) => const PlaceholderScreen(title: 'Analytics'),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) => CustomTransitionPage<void>(
                key: state.pageKey,
                child: const SettingsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ];
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
    if (currentLocation.startsWith('/scan')) { // Placeholder route name
      return 1;
    }
    if (currentLocation.startsWith('/sales')) { // Placeholder route name
      return 2;
    }
    if (currentLocation.startsWith('/analytics')) { // Placeholder route name
      return 3;
    }
    if (currentLocation.startsWith('/settings')) {
      return 4; // Updated index
    }
    // Default to Home/Inventory
    return 0;
  }

  // Helper for navigation logic
  void _navigate(BuildContext scaffoldContext, int index, String currentLocation) {
     bool drawerIsOpen = false;
     // Check if the Scaffold has a drawer and if it's open
     // Use maybeOf to handle cases where Scaffold or drawer might not be present immediately
     final scaffoldState = Scaffold.maybeOf(scaffoldContext);
     if (scaffoldState?.hasDrawer ?? false) {
        drawerIsOpen = scaffoldState!.isDrawerOpen;
     }

     if (drawerIsOpen) {
       // Use root navigator to ensure drawer context isn't lost
       Navigator.of(scaffoldContext, rootNavigator: true).pop();
     }

    // Use Future.delayed to allow the drawer to close before navigating
    // Increased delay slightly for smoother drawer closing
    Future.delayed(drawerIsOpen ? const Duration(milliseconds: 100) : Duration.zero, () {
      if (!scaffoldContext.mounted) return;
      final router = GoRouter.of(scaffoldContext);

      switch (index) {
        case 0:
          if (!currentLocation.startsWith('/home')) router.go('/home');
          break;
        case 1:
          // TODO: Define and navigate to '/scan' route
          if (!currentLocation.startsWith('/scan')) router.go('/scan'); // Placeholder
          break;
        case 2:
          // TODO: Define and navigate to '/sales' route
          if (!currentLocation.startsWith('/sales')) router.go('/sales'); // Placeholder
          break;
        case 3:
          // TODO: Define and navigate to '/analytics' route
          if (!currentLocation.startsWith('/analytics')) router.go('/analytics'); // Placeholder
          break;
        case 4:
          if (!currentLocation.startsWith('/settings')) router.go('/settings');
          break;
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
                    child: Text(
                      'Pallet Pro',
                      style: Theme.of(drawerContext).textTheme.titleLarge?.copyWith(
                        color: Theme.of(drawerContext).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  ListTile(
                    // Using 'Home' icon and label for consistency
                    leading: const Icon(Icons.home_filled),
                    title: const Text('Home'), // Changed from Inventory
                    selected: selectedIndex == 0,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 0, currentLocation),
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner), // Placeholder icon
                    title: const Text('Scan/Add'), // Placeholder label
                    selected: selectedIndex == 1,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 1, currentLocation), // Placeholder
                  ),
                   ListTile(
                    leading: const Icon(Icons.receipt_long), // Placeholder icon
                    title: const Text('Sales'), // Placeholder label
                    selected: selectedIndex == 2,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 2, currentLocation), // Placeholder
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics), // Placeholder icon
                    title: const Text('Analytics'), // Placeholder label
                    selected: selectedIndex == 3,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 3, currentLocation), // Placeholder
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    selected: selectedIndex == 4, // Updated index
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 4, currentLocation), // Updated index
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
        // Use Builder to get context below the Scaffold for sign-out SnackBar etc.
        body: Builder(
          builder: (scaffoldBodyContext) {
            // The AppBar no longer needs Settings/Logout actions.
            return Column(
              children: [
                AppBar(
                  title: const Text('Pallet Pro'),
                  // No back button automatically if it's a top-level route in Shell
                  // No leading hamburger icon needed for BottomNav
                  actions: [
                    // Add Sign Out button for mobile layout
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Sign Out',
                      // Use scaffoldBodyContext for ScaffoldMessenger access within _signOut
                      onPressed: () => _signOut(scaffoldBodyContext, ref),
                    ),
                  ], 
                ),
                Expanded(child: child), // Main content takes remaining space
              ],
            );
          }
        ),
        // Updated BottomNavigationBar
        bottomNavigationBar: BottomNavigationBar(
          // Set type to fixed when there are more items to prevent shifting
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          // Use context from Builder above if needed, but GoRouter uses root context usually
          onTap: (index) => _navigate(context, index, currentLocation),
          items: const [
            BottomNavigationBarItem(
              // Using 'Home' icon and label for consistency
              icon: Icon(Icons.home_filled),
              label: 'Home', // Changed from Inventory
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), // Placeholder icon
              label: 'Scan/Add', // Placeholder label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), // Placeholder icon
              label: 'Sales', // Placeholder label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics), // Placeholder icon
              label: 'Analytics', // Placeholder label
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

/// Simple placeholder screen for undeveloped features
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Note: This screen doesn't have its own AppBar because it's rendered
    // inside the AppShell which already provides one.
    return Center(
      child: Text(
        '$title Screen - Coming Soon!',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
