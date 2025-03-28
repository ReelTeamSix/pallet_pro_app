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
import 'package:supabase_flutter/supabase_flutter.dart';

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
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      notifyListeners();
    });
    
    // Listen to user settings changes
    ref.listen(userSettingsControllerProvider, (previous, next) {
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
    if (currentPath == '/home' && state.queryParameters['fromOnboarding'] == 'true') {
      debugPrint('RouterNotifier: Direct navigation from onboarding to home, bypassing settings checks');
      return null;
    }
    
    // Check the user settings to determine the next steps
    final userSettingsAsync = ref.read(userSettingsControllerProvider);
    
    if (!userSettingsAsync.hasValue || userSettingsAsync.value == null) {
      debugPrint('RouterNotifier: No user settings available, may be loading');
      
      // If settings are still loading or unavailable, don't redirect yet
      if (isOnboardingRoute || isBiometricSetupRoute || isBiometricAuthRoute) {
        debugPrint('RouterNotifier: On special route, not redirecting');
        return null;
      }
      
      // For other routes, try to go to onboarding
      if (!isOnboardingRoute) {
        debugPrint('RouterNotifier: Redirecting to onboarding as settings are not loaded');
        return '/onboarding';
      }
      
      return null;
    }
    
    // Now we have user settings
    final userSettings = userSettingsAsync.value!;
    debugPrint('RouterNotifier: User settings available, hasCompletedOnboarding=${userSettings.hasCompletedOnboarding}');
    
    // Check if biometric auth is required
    if (isLoggedIn && !isBiometricAuthRoute && !isBiometricSetupRoute && 
        !isOnboardingRoute && _shouldShowBiometricAuth()) {
      debugPrint('RouterNotifier: Biometric auth required, redirecting');
      _isBiometricAuthShowing = true;
      return '/biometric-auth';
    }

    // Reset the resumed flag once we've handled it
    if (_wasResumed) {
      _wasResumed = false;
    }

    // Reset the biometric auth showing flag once we've navigated away
    if (!isBiometricAuthRoute && _isBiometricAuthShowing) {
      _isBiometricAuthShowing = false;
    }

    // Onboarding flow
    if (!userSettings.hasCompletedOnboarding) {
      // User hasn't completed onboarding, make sure they're on the onboarding screen
      if (!isOnboardingRoute) {
        debugPrint('RouterNotifier: User needs onboarding, redirecting');
        return '/onboarding';
      }
    } else {
      // User has completed onboarding
      
      // If they're still on the onboarding screen, move them to either
      // biometric setup (if not set up) or home
      if (isOnboardingRoute) {
        if (!userSettings.useBiometricAuth && !isBiometricSetupRoute && !kIsWeb) {
          debugPrint('RouterNotifier: Onboarding completed, redirecting to biometric setup');
          return '/biometric-setup';
        } else {
          debugPrint('RouterNotifier: Onboarding completed, redirecting to home');
          return '/home';
        }
      }
      
      // If they're on the biometric setup screen but already have biometrics set up,
      // redirect them to home
      if (isBiometricSetupRoute && userSettings.useBiometricAuth) {
        debugPrint('RouterNotifier: Biometrics already set up, redirecting to home');
        return '/home';
      }
    }

    // No redirect needed
    return null;
  }
  
  /// Determines if biometric authentication should be shown.
  bool _shouldShowBiometricAuth() {
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
    
    // Check if biometric auth is enabled in user settings
    final userSettingsAsync = ref.read(userSettingsControllerProvider);
    if (!userSettingsAsync.hasValue || userSettingsAsync.value == null) {
      debugPrint('RouterNotifier: User settings not available, userSettingsAsync.hasValue=${userSettingsAsync.hasValue}');
      return false;
    }
    
    final useBiometricAuth = userSettingsAsync.value!.useBiometricAuth;
    debugPrint('RouterNotifier: useBiometricAuth=$useBiometricAuth');
    if (!useBiometricAuth) {
      return false;
    }
    
    // Check if biometric auth is available on this device
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
class SplashScreen extends StatefulWidget {
  /// Creates a new [SplashScreen] instance.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay for the splash screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Let the router decide where to go based on auth state and user settings
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with actual logo
            const Icon(
              Icons.view_module_outlined,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pallet Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isSettingsScreen = currentLocation == '/settings';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallet Pro'),
        actions: [
          // Settings button
          if (!isSettingsScreen)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () => context.go('/settings'),
            ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).signOut();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e is AppException 
                            ? e.message 
                            : 'Failed to sign out: ${e.toString()}'
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentLocation == '/home' ? 0 : 1,
        onTap: (index) {
          if (index == 0 && currentLocation != '/home') {
            context.go('/home');
          } else if (index == 1 && currentLocation != '/settings') {
            context.go('/settings');
          }
        },
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
