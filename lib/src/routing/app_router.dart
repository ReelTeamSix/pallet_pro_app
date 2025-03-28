import 'dart:io';

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
final routerProvider = NotifierProvider<RouterNotifier, GoRouter>(() {
  return RouterNotifier();
});

/// The router notifier.
class RouterNotifier extends Notifier<GoRouter> implements Listenable {
  VoidCallback? _routerListener;
  
  // Flag to track if the app was recently resumed
  bool _wasResumed = false;
  
  // Track if biometric auth is currently being shown
  bool _isBiometricAuthShowing = false;
  
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
  GoRouter build() {
    // Listen to user settings changes. This provider depends on auth state,
    // so listening here implicitly covers auth changes as well.
    ref.listen(userSettingsControllerProvider, (previous, next) {
      debugPrint('RouterNotifier: UserSettingsProvider changed, notifying listeners.');
      notifyListeners();
    });
    
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      refreshListenable: this,
      redirect: _redirectLogic,
      routes: _routes,
    );
  }

  @override
  void notifyListeners() {
    if (_routerListener != null) {
      _routerListener!();
    }
  }
  
  /// Called when the app is resumed
  void appResumed() {
    _wasResumed = true;
    notifyListeners();
  }

  /// The routes for the application.
  List<RouteBase> get _routes => [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
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
          builder: (context, state) => const BiometricAuthScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            // Add more routes here as needed
          ],
        ),
      ];

  /// The redirect logic for the application.
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    debugPrint('RouterNotifier: Redirect check for ${state.matchedLocation}');
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    debugPrint('RouterNotifier: isLoggedIn=$isLoggedIn, userId=${user?.id}');
    
    final isSplash = state.matchedLocation == '/splash';
    final isLoginRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    final isOnboardingRoute = state.matchedLocation == '/onboarding';
    final isBiometricAuthRoute = state.matchedLocation == '/biometric-auth';
    final isBiometricSetupRoute = state.matchedLocation == '/biometric-setup';

    // If the user is on the splash screen, wait for a moment
    // (the splash screen will navigate away after initialization)
    if (isSplash) {
      return null;
    }

    // If the user is not logged in, redirect to login
    if (!isLoggedIn) {
      debugPrint('RouterNotifier: Not logged in, redirecting to login');
      return isLoginRoute ? null : '/login';
    }

    // If the user is logged in but on a login route, redirect to home
    if (isLoggedIn && isLoginRoute) {
      debugPrint('RouterNotifier: Logged in but on login route, redirecting to home');
      return '/home';
    }

    // Bypass user settings checks for home route if we just came from onboarding
    final currentPath = state.matchedLocation;
    if (currentPath == '/home' && state.uri.queryParameters['fromOnboarding'] == 'true') {
      // ref.read(onboardingControllerProvider.notifier).setOnboardingFlowComplete(false); // Removed this line
    }
    
    // Check the user settings to determine the next steps
    final userSettingsAsync = ref.read(userSettingsControllerProvider);
    
    // --- Start Modification: Use userSettingsAsync.when for robust state handling ---
    return userSettingsAsync.when(
      data: (userSettings) {
        // *** CRITICAL CHECK ***: Ensure settings are not null and belong to the current user
        if (userSettings == null || userSettings.userId != user?.id) {
          debugPrint('RouterNotifier: Settings loaded but null or for wrong user (Expected: ${user?.id}, Got: ${userSettings?.userId}). Waiting/blocking protected routes.');
          if (isSplash || isLoginRoute || isOnboardingRoute || isBiometricSetupRoute || isBiometricAuthRoute) {
            return null; // Allow safe routes while waiting for correct settings
          }
          return null; // Block protected routes
        }
        
        // Settings are valid and for the current user
        debugPrint('RouterNotifier: User settings available for user ${userSettings.userId}, hasCompletedOnboarding=${userSettings.hasCompletedOnboarding}');
        
        // Check if biometric auth is required
        if (isLoggedIn && !isBiometricAuthRoute && !isBiometricSetupRoute && 
            !isOnboardingRoute && _shouldShowBiometricAuth(userSettings)) { // Pass valid userSettings
          debugPrint('RouterNotifier: Biometric auth required, redirecting');
          _isBiometricAuthShowing = true;
          return '/biometric-auth';
        }
        
        // Onboarding flow
        if (!userSettings.hasCompletedOnboarding) {
          if (!isOnboardingRoute) {
            debugPrint('RouterNotifier: User needs onboarding, redirecting');
            return '/onboarding';
          }
        } else {
          // User has completed onboarding
          if (isOnboardingRoute) {
            if (!userSettings.useBiometricAuth && !isBiometricSetupRoute && !kIsWeb) {
              debugPrint('RouterNotifier: Onboarding completed, redirecting to biometric setup');
              return '/biometric-setup';
            } else {
              debugPrint('RouterNotifier: Onboarding completed, redirecting to home');
              return '/home';
            }
          }
          if (isBiometricSetupRoute && userSettings.useBiometricAuth) {
            debugPrint('RouterNotifier: Biometrics already set up, redirecting to home');
            return '/home';
          }
        }
        
        // If logged in, settings loaded, onboarding done, and no other redirect needed...
        // Reset flags here if appropriate, moved from outside the .when()
        if (_wasResumed) _wasResumed = false;
        if (!isBiometricAuthRoute && _isBiometricAuthShowing) _isBiometricAuthShowing = false;
        
        debugPrint('RouterNotifier: Settings valid, no redirect condition met.');
        return null; // No redirect needed
      },
      loading: () {
        debugPrint('RouterNotifier: User settings are loading...');
        if (isSplash || isLoginRoute || isOnboardingRoute || isBiometricSetupRoute || isBiometricAuthRoute) {
          debugPrint('RouterNotifier: On loading/auth/setup route, allowing navigation while settings load.');
          return null; // Allow safe routes
        }
        debugPrint('RouterNotifier: Trying to access protected route while settings load, blocking navigation for now.');
        return null; // Block protected routes
      },
      error: (error, stackTrace) {
        debugPrint('RouterNotifier: Error loading user settings: $error');
        // Handle error state
        if (!isLoggedIn) {
          // Error and not logged in, safe to go to login
          return isLoginRoute ? null : '/login';
        } else {
          // Error but logged in. Could be a temporary issue.
          debugPrint('RouterNotifier: Settings error but logged in, blocking protected routes.');
          if (isSplash || isLoginRoute || isOnboardingRoute || isBiometricSetupRoute || isBiometricAuthRoute) {
            return null; // Allow safe routes
          }
          return null; // Block protected routes
        }
      },
    );
    // --- End Modification ---
  }
  
  /// Determines if biometric authentication should be shown.
  // Pass UserSettings to avoid re-reading stale state
  bool _shouldShowBiometricAuth(UserSettings userSettings) {
    debugPrint('RouterNotifier: _shouldShowBiometricAuth called');
    
    // Skip on web
    if (kIsWeb) {
      debugPrint('RouterNotifier: Web platform detected, skipping biometric auth');
      return false;
    }
    
    // Skip if not resumed or already showing biometric auth
    if (!_wasResumed || _isBiometricAuthShowing) {
      debugPrint('RouterNotifier: Not resumed or already showing biometric auth, _wasResumed=$_wasResumed, _isBiometricAuthShowing=$_isBiometricAuthShowing');
      return false;
    }
    
    // Use the passed userSettings directly
    final useBiometricAuth = userSettings.useBiometricAuth;
    debugPrint('RouterNotifier: useBiometricAuth=$useBiometricAuth');
    if (!useBiometricAuth) {
      return false;
    }
    
    // Check platform
    if (!(Platform.isAndroid || Platform.isIOS)) {
      debugPrint('RouterNotifier: Not Android or iOS platform');
      return false;
    }
    
    // Check if biometric auth is available on this device
    final biometricService = ref.read(biometricServiceProvider);
    final isBiometricAvailable = biometricService.isBiometricAvailableSync();
    debugPrint('RouterNotifier: isBiometricAvailable=$isBiometricAvailable');
    if (!isBiometricAvailable) {
      return false;
    }
    
    debugPrint('RouterNotifier: All conditions met, showing biometric auth');
    return true;
  }
}

/// The splash screen.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a new [SplashScreen] instance.
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigationInitiated = false; // Flag to ensure navigation happens only once

  void _navigateWhenReady(AsyncValue<User?> authState, AsyncValue<UserSettings?> settingsState) {
    // Prevent multiple navigation attempts
    if (_navigationInitiated) {
      return;
    }

    // We are ready to navigate if:
    // 1. Auth state is determined (not loading/error for initial check)
    // 2. EITHER auth succeeded AND settings are determined (not loading/error)
    //    OR auth failed (user is null)
    final authReady = !authState.isLoading; // Consider !authState.hasError as well if needed
    final settingsReady = !settingsState.isLoading; // Consider !settingsState.hasError
    final userLoggedIn = authState.valueOrNull != null;

    if (authReady && ((userLoggedIn && settingsReady) || !userLoggedIn)) {
      debugPrint('SplashScreen: Auth and Settings ready (UserLoggedIn: $userLoggedIn), initiating navigation...');
      
      // Set flag immediately to prevent re-entry
      _navigationInitiated = true; 

      // Let the router's redirect logic handle the destination
      if (mounted) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             context.go('/home');
           }
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the providers directly in build
    final authState = ref.watch(authControllerProvider);
    final settingsState = ref.watch(userSettingsControllerProvider);

    _navigateWhenReady(authState, settingsState);

    // Keep showing splash UI while waiting
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with actual logo
            Icon(
              Icons.view_module_outlined,
              size: 100,
              color: Colors.blue,
            ),
            SizedBox(height: 24),
            Text(
              'Pallet Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

/// The app shell.
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
        await ref.read(authControllerProvider.notifier).signOut();
      } catch (e) {
        if (scaffoldContext.mounted) {
          if (Scaffold.of(scaffoldContext).isDrawerOpen) {
            Navigator.of(scaffoldContext).pop();
          } 
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

    // Use kIsWeb for simplicity, refine with screen width checks if needed
    final bool useDrawerLayout = kIsWeb || !Platform.isIOS && !Platform.isAndroid; 

    if (useDrawerLayout) {
      // Web/Desktop Layout using Drawer
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pallet Pro'),
          // Drawer icon will be added automatically by Scaffold
        ),
        drawer: Drawer(
          child: Builder(
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
        appBar: AppBar(
          title: const Text('Pallet Pro'),
          actions: [
             // Settings button - only on mobile if not on settings screen
            if (selectedIndex != 1)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => _navigate(context, 1, currentLocation), 
              ),
            // Logout button - keep on AppBar for mobile?
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () => _signOut(context, ref),
            ),
          ],
        ),
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
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
