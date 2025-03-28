import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/biometric_auth_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
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
            // Add more routes here as needed
          ],
        ),
      ];

  /// The redirect logic for the application.
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final isSplash = state.matchedLocation == '/splash';
    final isLoginRoute =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    final isOnboardingRoute = state.matchedLocation == '/onboarding';
    final isBiometricAuthRoute = state.matchedLocation == '/biometric-auth';

    // If the user is on the splash screen, wait for a moment
    // (the splash screen will navigate away after initialization)
    if (isSplash) {
      return null;
    }

    // If the user is not logged in, redirect to login
    if (!isLoggedIn) {
      return isLoginRoute ? null : '/login';
    }

    // If the user is logged in but on a login route, redirect to home
    if (isLoggedIn && isLoginRoute) {
      return '/home';
    }

    // Check if biometric auth is required
    if (isLoggedIn && !isBiometricAuthRoute && _shouldShowBiometricAuth()) {
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

    // Check if the user has completed onboarding
    final userSettingsAsync = ref.read(userSettingsControllerProvider);
    if (userSettingsAsync.hasValue && userSettingsAsync.value != null) {
      final hasCompletedOnboarding = userSettingsAsync.value!.hasCompletedOnboarding;
      
      if (isLoggedIn && !hasCompletedOnboarding && !isOnboardingRoute) {
        return '/onboarding';
      }
    }

    // If the user is logged in and on the onboarding route but has completed it, redirect to home
    if (isLoggedIn && isOnboardingRoute && userSettingsAsync.hasValue && 
        userSettingsAsync.value != null && userSettingsAsync.value!.hasCompletedOnboarding) {
      return '/home';
    }

    // No redirect needed
    return null;
  }
  
  /// Determines if biometric authentication should be shown.
  bool _shouldShowBiometricAuth() {
    // Temporarily disable biometric auth until we fix the issues
    return false;
    
    /* Original implementation - commented out until fixed
    // Skip on web
    if (kIsWeb) {
      return false;
    }
    
    // For testing purposes, we'll always show biometric auth when the app is resumed
    // in debug mode on mobile platforms
    if (kDebugMode && _wasResumed && (Platform.isAndroid || Platform.isIOS)) {
      return true;
    }
    
    // Skip if not resumed or already showing biometric auth
    if (!_wasResumed || _isBiometricAuthShowing) {
      return false;
    }
    
    // Check if biometric auth is enabled in user settings
    final userSettingsAsync = ref.read(userSettingsControllerProvider);
    if (!userSettingsAsync.hasValue || userSettingsAsync.value == null) {
      return false;
    }
    
    final useBiometricAuth = userSettingsAsync.value!.useBiometricAuth;
    if (!useBiometricAuth) {
      return false;
    }
    
    // Check if biometric auth is available on this device
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return false;
    }
    
    return true;
    */
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
    // TODO: Implement app shell with navigation drawer or bottom navigation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pallet Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
    );
  }
}
