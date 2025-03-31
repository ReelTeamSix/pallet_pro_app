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
import 'package:pallet_pro_app/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:pallet_pro_app/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
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

/// Enum to represent specific navigation targets after certain auth flows.
enum _PostAuthNavigationTarget {
  none,
  homeAfterForcedLogin,
}

/// Manages routing logic and triggers refreshes based on auth/settings state.
class RouterNotifier extends Notifier<void> implements Listenable {
  VoidCallback? _routerListener;
  bool _wasResumed = false;
  bool _isNotifying = false;
  bool _isOnSettingsScreen = false;
  // Flag to track if the *initial* authentication check after login has passed.
  bool _initialAuthDone = false;
  // --- NEW STATE ---
  // Track specific navigation intent after forced sign-out
  // Using a backing field pattern to add debug logging on changes
  _PostAuthNavigationTarget _postAuthTargetValue = _PostAuthNavigationTarget.none;
  
  // Getter and setter with debug logging
  _PostAuthNavigationTarget get _postAuthTarget => _postAuthTargetValue;
  set _postAuthTarget(_PostAuthNavigationTarget value) {
    if (_postAuthTargetValue != value) {
      debugPrint('RouterNotifier: _postAuthTarget changing from $_postAuthTargetValue to $value');
      _postAuthTargetValue = value;
    }
  }
  // --- END NEW STATE ---
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
                              
      final userJustSignedIn = previous?.hasValue == true && previous?.value == null &&
                             next?.hasValue == true && next?.value != null;

      if (userJustSignedOut) {
        debugPrint('RouterNotifier: User signed out, resetting initial auth/resume flags.');
        // Explicitly preserve _postAuthTarget when signing out
        final targetBeforeSignOut = _postAuthTarget;
        debugPrint('RouterNotifier: Preserving post-auth target during sign-out: $targetBeforeSignOut');
        
        _initialAuthDone = false;
        _wasResumed = false; // Reset resume flag on sign out
        
        // Explicitly restore _postAuthTarget to preserve it during sign-out
        _postAuthTarget = targetBeforeSignOut;
      } else if (userJustSignedIn) {
        // For sign in, preserve the post auth target
        final targetBeforeSignIn = _postAuthTarget;
        debugPrint('RouterNotifier: User signed in, current postAuthTarget: $targetBeforeSignIn');
        // Don't reset or change _postAuthTarget here
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
      // Preserve our post-auth target during sign-out
      final currentTarget = _postAuthTarget;
      debugPrint('RouterNotifier: Sign-out detected, immediately notifying. Preserving postAuthTarget: $currentTarget');
      
      _lastNotification = DateTime.now();
      // Force immediate redirect on sign-out without debouncing
      Future.microtask(() {
        debugPrint('RouterNotifier: Force immediate redirect for sign-out. PostAuthTarget: $currentTarget');
        
        // Save the current target before notifying listeners
        final savedTarget = _postAuthTarget;
        notifyListeners();
        
        // Restore the target after notifying, as it may have been reset during redirection
        if (_postAuthTarget != savedTarget) {
          debugPrint('RouterNotifier: Restoring postAuthTarget after sign-out redirect: $savedTarget');
          _postAuthTarget = savedTarget;
        }
      });
      return;
    }

    // Check for sign-in event
    final isSignInEvent = providerName == 'AuthController' && 
                         previous is AsyncData<User?> && 
                         next is AsyncData<User?> && 
                         (previous as AsyncData<User?>).value == null && 
                         (next as AsyncData<User?>).value != null;
                         
    if (isSignInEvent) {
      // Preserve our post-auth target during sign-in
      final currentTarget = _postAuthTarget;
      debugPrint('RouterNotifier: Sign-in detected. Current postAuthTarget: $currentTarget');
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
      
      // Save current target before refresh
      final savedTarget = _postAuthTarget;
      _debouncedNotifyListeners();
      
      // After debounced notification, check if we need to restore the target
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_postAuthTarget != savedTarget && savedTarget != _PostAuthNavigationTarget.none) {
          debugPrint('RouterNotifier: Restoring postAuthTarget after state change: $savedTarget');
          _postAuthTarget = savedTarget;
        }
      });
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

  /// Sets the state to ensure the next redirect after login goes directly home,
  /// bypassing the initial auth check.
  /// Called by LoginScreen upon successful login *if* coming from forced sign-out.
  void prepareForForcedLoginRedirect() {
      debugPrint('RouterNotifier: Preparing for post-forced-sign-out redirect to home.');
      _postAuthTarget = _PostAuthNavigationTarget.homeAfterForcedLogin;
  }

  /// Resets the post-auth target if it was set, e.g., after login failure.
  void resetPostAuthTarget() {
    if (_postAuthTarget != _PostAuthNavigationTarget.none) {
      debugPrint('RouterNotifier: Resetting post-auth target due to login failure or cancellation.');
      _postAuthTarget = _PostAuthNavigationTarget.none;
    }
  }

  /// Debug method to get the current post auth target value.
  _PostAuthNavigationTarget debugGetPostAuthTarget() {
    debugPrint('RouterNotifier: Current _postAuthTarget = $_postAuthTarget');
    return _postAuthTarget;
  }

  /// The core redirect logic.
  String? _redirectLogic(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final queryParams = state.uri.queryParameters;
    final from = queryParams['from'] ?? '';
    final reason = queryParams['reason'] ?? '';

    final isFromAuth = from == 'biometric' || from == 'pin' || from == 'cancel_initial';
    if (isFromAuth && location == '/login') {
      debugPrint('RouterNotifier: Login screen has auth source query parameter: $from');
      if (_postAuthTarget == _PostAuthNavigationTarget.none) {
        debugPrint('RouterNotifier: Setting postAuthTarget to homeAfterForcedLogin from query param');
        _postAuthTarget = _PostAuthNavigationTarget.homeAfterForcedLogin;
      }
    }

    debugPrint(
        'RouterNotifier: Redirect check | Location: $location | Params: $queryParams | Reason: $reason | From: $from | InitialAuthDone: $_initialAuthDone | WasResumed: $_wasResumed | PostAuthTarget: $_postAuthTarget');

    try {
      // --- 0. Handle Password Recovery --- 
      final recoveryToken = ref.read(passwordRecoveryTokenProvider);
      if (recoveryToken != null) {
        debugPrint('RouterNotifier: Password recovery token found. Redirecting.');
        
        // Redirect to reset password screen if not already there
        if (location != '/reset-password') {
          // Pass the token via query parameters? Or rely on AuthController having it?
          // For simplicity, let's assume ResetPasswordScreen will retrieve it later.
          return '/reset-password?from=recovery_link';
        } else {
          // Already on the correct screen, stay put.
          return null;
        }
      }
      
      // Snapshot providers (after recovery check)
      final authActionState = ref.read(authControllerProvider);
      final rawAuthState = ref.read(authStateChangesProvider);
      final settingsState = ref.read(userSettingsControllerProvider);

      final isSplash = location == '/splash';
      final isLoginOrSignupRoute = location == '/login' || location == '/signup';
      final isOnboardingRoute = location == '/onboarding';
      final isBiometricAuthRoute = location == '/biometric-auth';
      final isPinAuthRoute = location == '/pin-auth';
      final isBiometricSetupRoute = location == '/biometric-setup';
      final isPinSetupRoute = location == '/pin-setup';
      final isForgotPasswordRoute = location == '/forgot-password';
      final isResetPasswordRoute = location == '/reset-password';

      // --- 1. Handle VERY Initial Raw Auth Load ---
      final isRawAuthLoading = !rawAuthState.hasValue && !rawAuthState.hasError;
      final splashWaitedTooLong = DateTime.now().difference(_appStartTime) > _maxSplashWaitTime;
      if (splashWaitedTooLong && isSplash) {
        debugPrint('RouterNotifier: Auth initialization timeout. Forcing redirect to login.');
        return '/login?from=timeout';
      }
      if (isRawAuthLoading) {
        debugPrint('RouterNotifier: Raw Auth loading. Staying on splash.');
        return isSplash ? null : '/splash';
      }

      // --- 2. Handle Raw Auth Error ---
      final rawAuthError = rawAuthState.error;
      if (rawAuthError != null) {
         debugPrint('RouterNotifier: Raw Auth Error: $rawAuthError. Redirecting to /login.');
         return isLoginOrSignupRoute ? null : '/login';
      }

      // --- 3. Handle Auth Action Loading ---
      final isAuthActionLoading = authActionState is AsyncLoading;
      if (isAuthActionLoading && !isSplash) {
        if (isLoginOrSignupRoute && from != 'timeout') {
           debugPrint('RouterNotifier: Auth action in progress. Redirecting to splash.');
           return '/splash?from=auth_action';
        }
      }
      if (isSplash && from == 'auth_action' && isAuthActionLoading) {
          debugPrint('RouterNotifier: Already on splash for auth action. Staying.');
          return null;
      }

      // --- 4. Raw Auth Resolved ---
      final user = rawAuthState.value?.session?.user;
      final isLoggedIn = user != null;

      // --- 4a. Not Logged In ---
      if (!isLoggedIn) {
        final isAllowedPublicRoute = isLoginOrSignupRoute || 
                                   isForgotPasswordRoute || 
                                   isResetPasswordRoute || 
                                   location == '/splash';
                                   
        debugPrint('RouterNotifier: Executing 4a (Not Logged In). Location: $location, Allowed Public: $isAllowedPublicRoute');
        if (!isAllowedPublicRoute) {
            debugPrint('RouterNotifier: Not logged in. Redirecting to /login.');
            _initialAuthDone = false; _wasResumed = false;
            return '/login?from=not_logged_in';
        }
        debugPrint('RouterNotifier: Not logged in, on allowed route ($location). Staying.');
        _initialAuthDone = false; _wasResumed = false;
        return null;
      }

      // --- 4b. Logged In - Check Settings ---
      debugPrint('RouterNotifier: Logged In as ${user.id}. Checking settings...');
      final isSettingsLoading = !settingsState.hasValue && !settingsState.hasError;
      final settingsError = settingsState.error;
      if (isSettingsLoading && !isSplash && from != 'settings_loading') {
          debugPrint('RouterNotifier: Settings loading. Forcing to splash.');
          return '/splash?from=settings_loading';
      }
      if (isSplash && isSettingsLoading) {
          debugPrint('RouterNotifier: Already at splash waiting for settings. Staying.');
          return null;
      }
      if (settingsError != null) {
           debugPrint('RouterNotifier: Settings Error. Redirecting to /login.');
           _initialAuthDone = false; _wasResumed = false;
           return isLoginOrSignupRoute ? null : '/login';
      }

      // --- 5. Logged In, Settings Loaded Successfully ---
      final userSettings = settingsState.value;
      if (userSettings == null) {
         if (isSplash || isLoginOrSignupRoute) {
           debugPrint('RouterNotifier: Settings null (race?). Staying on waiting screen.');
           return null;
         }
         debugPrint('RouterNotifier: Settings null unexpectedly. Redirecting to /splash.');
         return '/splash?from=waiting_settings_race';
      }

      // --- 5a. Handle Forced Login Redirect ---
      // Check this *before* onboarding or standard auth checks
      debugPrint('RouterNotifier: Checking for forced login redirect. PostAuthTarget: $_postAuthTarget');
      
      // Set the target if we're on login with from=biometric or from=pin, even if not already set
      if ((from == 'biometric' || from == 'pin' || from == 'cancel_initial') && isLoginOrSignupRoute && _postAuthTarget == _PostAuthNavigationTarget.none) {
        debugPrint('RouterNotifier: On login with auth source, setting home redirect flag');
        _postAuthTarget = _PostAuthNavigationTarget.homeAfterForcedLogin;
      }
      
      if (_postAuthTarget == _PostAuthNavigationTarget.homeAfterForcedLogin) {
        debugPrint('RouterNotifier: REDIRECTING - Post-forced-sign-out login detected, going directly to home.');
        _postAuthTarget = _PostAuthNavigationTarget.none; // Consume the target state
        _initialAuthDone = true; // Mark initial auth as complete for this session
        _wasResumed = false; // Ensure resume check doesn't trigger immediately
        return '/home?from=forced_login_complete'; // Go directly to home
      } else {
        debugPrint('RouterNotifier: No forced login redirect needed.');
      }
      // --- End Forced Login Handling ---

      debugPrint('RouterNotifier: Logged In & Settings Loaded | Onboarding: ${userSettings.hasCompletedOnboarding} | UseBio: ${userSettings.useBiometricAuth} | UsePIN: ${userSettings.usePinAuth} | InitialAuthDone: $_initialAuthDone | WasResumed: $_wasResumed');

      final isAuthRelatedRoute = isLoginOrSignupRoute || isOnboardingRoute || isBiometricAuthRoute || isBiometricSetupRoute || isPinAuthRoute || isPinSetupRoute || isSplash;
      final isOnProtectedLocation = !isAuthRelatedRoute;
      final bool canUseBiometrics = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

      // --- 6. Onboarding Check --- (Needs to run before auth checks)
      if (!(userSettings.hasCompletedOnboarding ?? false)) {
        debugPrint('RouterNotifier: Needs onboarding.');
        return isOnboardingRoute ? null : '/onboarding';
      }
      // --- User is onboarded from here --- 

      // --- 7. Determine if Auth Check is Required (Initial Launch or Resume) ---
      bool needsAuthCheck = false;
      String? authRoute;
      String authReason = '';
      bool bioAvailableAndEnabled = canUseBiometrics && (userSettings.useBiometricAuth ?? false);
      final bool pinEnabled = userSettings.usePinAuth ?? false;
      bool isResumeCheck = _wasResumed && isOnProtectedLocation;
      
      // Skip initial auth check on a direct login from auth screens
      final isDirectLogin = from == 'biometric' || from == 'pin' || from == 'cancel_initial';
      
      // If we had a post auth target set (or have one now), we should skip the initial auth check
      final shouldSkipInitialAuth = _postAuthTarget == _PostAuthNavigationTarget.homeAfterForcedLogin || 
                                   isDirectLogin || 
                                   from == 'forced_login_complete';
      
      // Only perform initial auth check if:
      // 1. It hasn't been done yet (_initialAuthDone is false)
      // 2. We're not coming from a forced login flow (shouldSkipInitialAuth is false)
      bool isInitialLaunchCheck = !_initialAuthDone && !shouldSkipInitialAuth;
      
      if (shouldSkipInitialAuth && !_initialAuthDone) {
        debugPrint('RouterNotifier: Skipping initial auth check due to direct login or target flag');
        _initialAuthDone = true; // Mark as done since we're bypassing
      }
      
      if (isResumeCheck) {
         // Consume the resume flag
         _wasResumed = false;
         debugPrint('RouterNotifier: Evaluating Resume Auth Check.');
         if (bioAvailableAndEnabled) {
            needsAuthCheck = true;
            authRoute = '/biometric-auth';
            authReason = 'resume_auth';
            debugPrint('RouterNotifier: Resume Check: Needs Biometric.');
         } else if (pinEnabled && !kIsWeb) {
            needsAuthCheck = true;
            authRoute = '/pin-auth';
            authReason = 'resume_auth';
            debugPrint('RouterNotifier: Resume Check: Needs PIN.');
         }
      }
      // Only do initial launch check if NOT resuming and initial auth isn't done
      else if (isInitialLaunchCheck) {
         debugPrint('RouterNotifier: Evaluating Initial Launch Auth Check.');
         // --- Original Initial Check Logic ---
         if (bioAvailableAndEnabled) {
            needsAuthCheck = true;
            authRoute = '/biometric-auth';
            authReason = 'initial_launch_auth';
            debugPrint('RouterNotifier: Initial Launch Check: Needs Biometric.');
         } else if (pinEnabled && !kIsWeb) {
            needsAuthCheck = true;
            authRoute = '/pin-auth';
            authReason = 'initial_launch_auth';
            debugPrint('RouterNotifier: Initial Launch Check: Needs PIN.');
         } else {
             // No auth method enabled, mark as done immediately
             debugPrint('RouterNotifier: Initial Launch: No bio/PIN enabled. Marking auth done.');
             _initialAuthDone = true;
         }
      }
      
      // --- 8. Execute Auth Redirect if Needed ---
      if (needsAuthCheck && authRoute != null) {
          // Allow navigation *between* auth methods even during initial check
          if (location == '/pin-auth' && from == 'biometric') {
             debugPrint('RouterNotifier: Allowing navigation from biometric to PIN auth screen.');
             return null; // Allow the navigation to pin-auth
          }
          // Hypothetical: Allow navigation from PIN to Biometric if PIN was primary
          // if (location == '/biometric-auth' && from == 'pin') {
          //    debugPrint('RouterNotifier: Allowing navigation from PIN to biometric auth screen.');
          //    return null; 
          // }
          
          // If we need auth check AND are not already on the correct auth route (and not navigating between auth types)
          if (location != authRoute) {
              debugPrint('RouterNotifier: Redirecting to required auth route: $authRoute?reason=$authReason');
              return '$authRoute?reason=$authReason';
          }
          // If we need auth check AND ARE already on the correct auth route
          else {
             debugPrint('RouterNotifier: Already on required auth route $authRoute for $reason. Staying.');
             return null; // Stay put and wait for user interaction
          }
      }

      // --- Auth Check Handled or Not Required --- 
      // If we reach here, it means: 
      // 1. No auth check was needed (bio/pin disabled or initial check done)
      // 2. Auth check was needed and we are waiting on the correct auth screen
      // Ensure _initialAuthDone is true if no check was triggered initially because bio/pin were disabled
      if (isInitialLaunchCheck && !needsAuthCheck) {
          _initialAuthDone = true; // Already logged above
      }

      // --- 9. Post-Auth/Onboarding Redirect --- 
      // If initial authentication is now complete (_initialAuthDone is true), 
      // and we are on a non-protected screen (splash/login/onboarding), redirect to home.
      if (_initialAuthDone && (isLoginOrSignupRoute || isOnboardingRoute || isSplash)) {
           debugPrint('RouterNotifier: Initial auth complete, redirecting from $location to /home.');
           return '/home?from=auth_complete';
      }

      // --- 10. Handle Setup Routes --- (After main auth flow)
      if (isBiometricSetupRoute && (userSettings.useBiometricAuth ?? false || !canUseBiometrics)) {
          debugPrint('RouterNotifier: On biometric setup but already setup/not applicable. Redirecting to /home.');
          return '/home';
      }
      if (isPinSetupRoute && (userSettings.pinHash != null && userSettings.pinHash!.isNotEmpty)) {
         debugPrint('RouterNotifier: On PIN setup but PIN exists. Redirecting to /home.');
         return '/home';
      }

      // --- 11. Handle Auth Route Conflicts --- 
      // Allow direct navigation from biometric to PIN auth if needed
      if (isPinAuthRoute && from == 'biometric') {
          debugPrint('RouterNotifier: Allowing direct navigation from biometric to PIN auth');
          return null;
      }
      // If user lands on auth route unexpectedly (not for initial/resume check)
      if (_initialAuthDone && (isBiometricAuthRoute || isPinAuthRoute) && reason != 'resume_auth' && reason != 'initial_launch_auth') {
          debugPrint('RouterNotifier: On auth route ($location) unexpectedly after auth complete. Redirecting to /home');
          return '/home';
      }

      // --- Default Case --- 
      debugPrint('RouterNotifier: All checks passed for $location. Allowing navigation.');
      // If we've reached here, user is logged in, onboarded, initial auth is complete, 
      // resume checks (if any) were handled, and we are likely on a protected route.
      return null;

    } catch (e, stack) {
      debugPrint('RouterNotifier: Error in redirect logic: $e\n$stack');
      return '/login?from=error_recovery'; // Fallback
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
          path: '/forgot-password',
          name: 'forgot_password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'reset_password',
          builder: (context, state) => const ResetPasswordScreen(),
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
                child: const DashboardScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
            GoRoute(
              path: '/inventory',
              name: 'inventory',
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
    if (currentLocation.startsWith('/inventory')) { // Check inventory first
      return 1;
    }
    if (currentLocation.startsWith('/sales')) {
      return 2;
    }
    if (currentLocation.startsWith('/analytics')) {
      return 3;
    }
    if (currentLocation.startsWith('/settings')) {
      return 4;
    }
    // Default to Dashboard/Home
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
          if (!currentLocation.startsWith('/inventory')) router.go('/inventory');
          break;
        case 2:
          if (!currentLocation.startsWith('/sales')) router.go('/sales');
          break;
        case 3:
          if (!currentLocation.startsWith('/analytics')) router.go('/analytics');
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
                    leading: const Icon(Icons.dashboard_outlined), // Dashboard icon
                    title: const Text('Dashboard'), // Dashboard label
                    selected: selectedIndex == 0,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 0, currentLocation),
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.inventory), // Inventory icon
                    title: const Text('Inventory'), // Inventory label
                    selected: selectedIndex == 1,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 1, currentLocation),
                  ),
                   ListTile(
                    leading: const Icon(Icons.attach_money), // Sales icon
                    title: const Text('Sales'), // Sales label
                    selected: selectedIndex == 2,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 2, currentLocation), // Placeholder
                  ),
                  ListTile(
                    leading: const Icon(AppIcons.analytics), // Analytics icon
                    title: const Text('Analytics'), // Analytics label
                    selected: selectedIndex == 3,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 3, currentLocation), // Placeholder
                  ),
                   ListTile(
                    leading: const Icon(AppIcons.settings), // Settings icon
                    title: const Text('Settings'), // Settings label
                    selected: selectedIndex == 4,
                    selectedTileColor: Theme.of(drawerContext).colorScheme.primaryContainer.withOpacity(0.1),
                    onTap: () => _navigate(drawerContext, 4, currentLocation),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Theme.of(drawerContext).colorScheme.error),
                    title: Text('Sign Out', style: TextStyle(color: Theme.of(drawerContext).colorScheme.error)),
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
                    // Remove Sign Out button from mobile layout AppBar
                    // IconButton(
                    //   icon: const Icon(Icons.logout),
                    //   tooltip: 'Sign Out',
                    //   // Use scaffoldBodyContext for ScaffoldMessenger access within _signOut
                    //   onPressed: () => _signOut(scaffoldBodyContext, ref),
                    // ),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.inventory),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Sales',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.analytics),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.settings),
              activeIcon: Icon(Icons.settings),
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
