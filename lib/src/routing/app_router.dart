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
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/add_edit_item_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/inventory_list_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/pallet_detail_screen.dart';
import 'package:pallet_pro_app/src/features/inventory/presentation/screens/item_detail_screen.dart';
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
  
  // Define route names for better management
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password'; // Assumes it needs a token
  static const onboarding = '/onboarding';
  static const pinSetup = '/pin-setup';
  static const pinAuth = '/pin-auth';
  static const biometricSetup = '/biometric-setup';
  static const biometricAuth = '/biometric-auth';
  static const home = '/home';
  static const settings = '/settings';
  // Inventory Routes
  static const inventoryList = '/inventory';
  static const palletDetail = '/inventory/pallet/:pid'; // pid = pallet id
  static const itemDetail = '/inventory/item/:iid'; // iid = item id
  // Add Item Route - placed in the proper hierarchy
  static const addEditItem = 'add-edit-item'; // Will be used with parent route
  static const addItemToPallet = '/inventory/pallet/:pid/add-item'; // Used for direct navigation

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

  /// Redirect logic based on auth state and user settings.
  FutureOr<String?> _redirectLogic(BuildContext context, GoRouterState state) async {
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

  /// Defines the routes for the application.
  List<RouteBase> get _routes => [
        GoRoute(
          path: splash,
          name: splash,
          builder: (context, state) => const Scaffold( // Simple splash screen
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: login,
          name: login,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: signup,
          name: signup,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const SignupScreen(),
          ),
        ),
         GoRoute(
          path: forgotPassword,
          name: forgotPassword,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const ForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: resetPassword,
          name: resetPassword,
          pageBuilder: (context, state) {
            final token = state.uri.queryParameters['access_token'];
             // Simple validation: Ensure token is present
             if (token == null || token.isEmpty) {
               // Redirect to login or show an error page if token is missing/invalid
               // For simplicity, showing an error scaffold
               return _buildPageWithTransition(
                 context: context,
                 state: state,
                 child: Scaffold(
                   appBar: AppBar(title: Text('Error')),
                   body: Center(child: Text("Invalid or missing reset token."))),
               );
             }
            return _buildPageWithTransition(
              context: context,
              state: state,
              child: ResetPasswordScreen(),
            );
          }
        ),
        GoRoute(
          path: onboarding,
          name: onboarding,
          pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const OnboardingScreen(),
          ),
        ),
        GoRoute(
          path: pinSetup,
          name: pinSetup,
           pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PinSetupScreen(),
          ),
          // TODO: Add redirect logic if PIN is already set?
        ),
         GoRoute(
          path: pinAuth,
          name: pinAuth,
           pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const PinAuthScreen(),
          ),
        ),
         GoRoute(
          path: biometricSetup,
          name: biometricSetup,
           pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const BiometricSetupScreen(),
          ),
        ),
         GoRoute(
          path: biometricAuth,
          name: biometricAuth,
           pageBuilder: (context, state) => _buildPageWithTransition(
            context: context,
            state: state,
            child: const BiometricAuthScreen(),
          ),
        ),
        // Shell Route for main app sections with bottom navigation (placeholder)
        // Using StatefulShellRoute for persistent navigation state
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              // Return the widget that contains the Scaffold with BottomNavigationBar
              // The navigationShell exposes the IndexedStack (or other widget)
              // that displays the current branch's navigator.
              // You might need a custom Scaffold wrapper here.
              // For now, just return the navigationShell directly for basic structure.
              // return AppShell(navigationShell: navigationShell); // Replace with your actual Shell UI
              // Placeholder: Directly return shell until AppShell is created
               return ScaffoldWithNavBar(navigationShell: navigationShell);
            },
            branches: [
                // Branch 1: Dashboard
                 StatefulShellBranch(
                     //navigatorKey: _shellNavigatorKey, // Use key if needed for deep linking/state
                     routes: [
                         GoRoute(
                             path: home,
                             name: home,
                             pageBuilder: (context, state) => _buildPageWithTransition(
                                 context: context,
                                 state: state,
                                 child: const DashboardScreen(), // Main Dashboard
                             ),
                              routes: [
                                // Settings is modal on mobile, full screen on others
                                GoRoute(
                                  path: settings, // Relative path
                                  name: settings, // Use the constant name
                                   pageBuilder: (context, state) {
                                    if (ResponsiveUtils.isMobile(context)) {
                                      return DialogPage( // Modal on mobile
                                         builder: (_) => const SettingsScreen(),
                                       );
                                     } else {
                                       return _buildPageWithTransition( // Full page on larger screens
                                         context: context,
                                         state: state,
                                         child: const SettingsScreen(),
                                       );
                                     }
                                   }
                                ),
                                // NEW: Inventory Routes Branching from Home/Dashboard
                                GoRoute(
                                  path: inventoryList, // Relative path: /home/inventory
                                  name: inventoryList, // Use the constant name
                                  pageBuilder: (context, state) => _buildPageWithTransition(
                                    context: context,
                                    state: state,
                                    child: const InventoryListScreen(),
                                  ),
                                  routes: [
                                    GoRoute(
                                      path: palletDetail, // Relative path: /home/inventory/pallet/:pid
                                      name: palletDetail, // Use the constant name
                                      pageBuilder: (context, state) {
                                        final palletId = state.pathParameters['pid'];
                                        // TODO: Add error handling if pid is null
                                        return _buildPageWithTransition(
                                          context: context,
                                          state: state,
                                          child: PalletDetailScreen(palletId: palletId!),
                                        );
                                      },
                                      routes: [
                                        GoRoute(
                                          path: addEditItem, // Relative path: /home/inventory/pallet/:pid/add-edit-item
                                          name: addItemToPallet, // Named route for direct navigation
                                          pageBuilder: (context, state) {
                                            final palletId = state.pathParameters['pid'];
                                            final itemId = state.uri.queryParameters['itemId']; // Optional for editing
                                            
                                            return _buildPageWithTransition(
                                              context: context,
                                              state: state,
                                              child: AddEditItemScreen(
                                                palletId: palletId!, 
                                                item: null, // Item would be fetched separately if needed for editing
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    GoRoute(
                                      path: itemDetail, // Relative path: /home/inventory/item/:iid
                                      name: itemDetail, // Use the constant name
                                      pageBuilder: (context, state) {
                                        final itemId = state.pathParameters['iid'];
                                         // TODO: Add error handling if iid is null
                                        return _buildPageWithTransition(
                                          context: context,
                                          state: state,
                                          child: ItemDetailScreen(itemId: itemId!),
                                        );
                                      },
                                      // TODO: Add route for adding/editing items, potentially nested under pallet detail?
                                    ),
                                     // TODO: Add route for adding/editing pallets
                                  ],
                                ),
                              ]
                         ),
                     ],
                 ),
                  // Branch 2: Placeholder for maybe Analytics/Reports later
                 StatefulShellBranch(
                     routes: [
                         GoRoute(
                           path: '/reports', // Example placeholder
                           name: 'reports',
                           builder: (context, state) => Scaffold(
                             appBar: AppBar(title: const Text('Reports')),
                             body: Center(child: Text('Reports Screen (Placeholder)')),
                           ),
                         ),
                      ],
                 ),
                  // Branch 3: Placeholder for maybe Settings as a main tab (alternative)
                  // StatefulShellBranch(
                  //    routes: [
                  //        GoRoute(
                  //          path: '/settings-tab', // Example placeholder
                  //          name: 'settings-tab',
                  //          builder: (context, state) => const SettingsScreen(), // Reusing settings screen
                  //        ),
                  //     ],
                  // ),
            ],
        ),

        // Fallback route for unknown paths (optional)
        // GoRoute(path: '/', redirect: (_, __) => '/'), // Redirect unknown to root
      ];

  /// Helper for consistent page transitions (e.g., FadeTransition).
  static Page _buildPageWithTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    // Example: Use FadeTransition
     return CustomTransitionPage<T>(
       key: state.pageKey,
       child: child,
       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
     );
    // Or just MaterialPage for default transitions
    // return MaterialPage<T>(key: state.pageKey, child: child);
  }
  
  // --- App Lifecycle Listener ---
  // Called when the app lifecycle changes (e.g., resumed)
  void didChangeAppLifecycleState(AppLifecycleState state) {
     debugPrint("RouterNotifier: App Lifecycle State Changed: $state");
     if (state == AppLifecycleState.resumed) {
       // Only trigger resume logic if not recently authenticated
       final now = DateTime.now();
       final timeSinceLastAuth = _lastAuthCompletionTime != null 
                                   ? now.difference(_lastAuthCompletionTime!) 
                                   : const Duration(days: 1); // Treat as long ago if never authenticated

       if (timeSinceLastAuth > _authCooldownDuration) {
         debugPrint("RouterNotifier: App Resumed (and not recently authenticated).");
         _wasResumed = true;
          // Read auth state directly here to check if user exists
          final authState = ref.read(authControllerProvider);
          final settingsState = ref.read(userSettingsControllerProvider);
          final user = authState.valueOrNull;
          final settings = settingsState.valueOrNull;
          final hasPin = settings?.usePinAuth ?? false;
          final hasBiometrics = settings?.useBiometricAuth ?? false;
          final isBiometricSupported = ref.read(biometricServiceProvider).isBiometricAvailableSync();
          
           // Only trigger refresh if logged in and requires secondary auth
           if (user != null && (hasPin || (hasBiometrics && isBiometricSupported))) {
             debugPrint("RouterNotifier: Triggering debounced notification due to resume requiring auth.");
             // Preserve the post-auth target during resume
             final currentTarget = _postAuthTarget;
             debugPrint('RouterNotifier: Preserving postAuthTarget during resume: $currentTarget');
             _debouncedNotifyListeners();
              // Restore target after potential notification
             Future.delayed(const Duration(milliseconds: 150), () {
               if (_postAuthTarget != currentTarget) {
                 debugPrint('RouterNotifier: Restoring postAuthTarget after resume notification: $currentTarget');
                 _postAuthTarget = currentTarget;
               }
             });
           } else {
              debugPrint("RouterNotifier: App Resumed, but no user or no secondary auth required. No refresh needed.");
               _wasResumed = false; // Reset flag if no action needed
           }
       } else {
         debugPrint("RouterNotifier: App Resumed, but recently authenticated. Skipping resume logic.");
          _wasResumed = false; // Reset flag, auth is recent
       }
     } else if (state == AppLifecycleState.paused) {
       debugPrint("RouterNotifier: App Paused. Resetting initial auth flag.");
       // Reset the initial auth flag when paused, so it needs re-check on resume
       _initialAuthDone = false;
        // Preserve post-auth target when pausing
       final targetBeforePause = _postAuthTarget;
       debugPrint('RouterNotifier: Preserving post-auth target during pause: $targetBeforePause');
       // Explicitly ensure the target remains after reset potentially triggered by state change listeners
        _postAuthTarget = targetBeforePause; 
        
     } else if (state == AppLifecycleState.detached || state == AppLifecycleState.hidden) {
        // Handle detached state (app might be terminated)
         debugPrint("RouterNotifier: App Detached/Hidden.");
         // Consider cleanup or state persistence if needed
          _initialAuthDone = false; // Reset on detach as well
           // Preserve post-auth target when detaching
          final targetBeforeDetach = _postAuthTarget;
          debugPrint('RouterNotifier: Preserving post-auth target during detach/hide: $targetBeforeDetach');
          _postAuthTarget = targetBeforeDetach; 
     }
   }
}


// Helper class to observe route changes without direct GoRouter dependency in Notifier
class _RouterObserver extends NavigatorObserver {
  ValueChanged<String>? onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notifyPathChange(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _notifyPathChange(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _notifyPathChange(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _notifyPathChange(Route<dynamic> route) {
    // Extract path from route settings if available
    final path = route.settings.name;
    if (path != null) {
      onRouteChanged?.call(path);
       debugPrint('_RouterObserver: Route changed to: $path');
    } else {
       // Attempt to get path from GoRouter specific properties if Material/Cupertino page route
       if (route is PageRoute && route.settings is GoRoute) {
         // This might not be reliable or necessary depending on how GoRouter manages settings.name
         // Stick to route.settings.name if possible.
       }
       debugPrint('_RouterObserver: Route changed, but path is null (Route: ${route.runtimeType})');
    }
  }
}

// --- NEW Stateful Shell Route Scaffold ---
// A responsive Scaffold that adapts to different screen sizes
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Determine if we should use drawer layout (web) or bottom nav (mobile)
    final bool isWebLayout = !ResponsiveUtils.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _buildTitleForIndex(navigationShell.currentIndex),
        // Remove settings icon from app bar on mobile as it will be in the bottom nav
      ),
      // Only show drawer on web, not on mobile
      drawer: isWebLayout ? _buildDrawer(context) : null,
      body: navigationShell,
      // Only show bottom navigation on mobile, not on web
      bottomNavigationBar: !isWebLayout ? _buildBottomNavigationBar(context) : null,
    );
  }
  
  // Create drawer for web layout
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'Pallet Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              // Go to the root of the Dashboard branch
              GoRouter.of(context).go('/home');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              GoRouter.of(context).go('/home/inventory');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              navigationShell.goBranch(1);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              GoRouter.of(context).go('/home/settings');
              Navigator.pop(context);
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authControllerProvider.notifier).signOut();
                },
              );
            },
          ),
        ],
      ),
    );
  }
  
  // Create bottom navigation bar for mobile layout
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Inventory',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _getCurrentIndex(context),
      onTap: (index) => _handleNavTap(context, index),
      type: BottomNavigationBarType.fixed, // Required for more than 3 items
    );
  }
  
  // Get the current index for the bottom nav bar
  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouter.of(context).routeInformationProvider.value.uri.toString();
    if (location.startsWith('/home/inventory')) {
      return 1; // Inventory tab
    } else if (location.startsWith('/reports')) {
      return 2; // Reports tab
    } else if (location.startsWith('/home/settings')) {
      return 3; // Settings tab
    }
    return 0; // Default to Dashboard tab
  }
  
  // Handle navigation when a bottom nav item is tapped
  void _handleNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: // Dashboard
        // Use direct navigation to ensure we get to the Dashboard from any screen
        GoRouter.of(context).go('/home');
        break;
      case 1: // Inventory
        GoRouter.of(context).go('/home/inventory');
        break;
      case 2: // Reports
        navigationShell.goBranch(1);
        break;
      case 3: // Settings
        GoRouter.of(context).go('/home/settings');
        break;
    }
  }
  
  Widget _buildTitleForIndex(int index) {
    switch (index) {
      case 0:
        return const Text('Pallet Pro');
      case 1:
        return const Text('Pallet Pro');
      default:
        return const Text('Pallet Pro');
    }
  }
}


// Helper class for Modal Pages (like Settings on Mobile)
// Uses GoRouter's features for platform-adaptive dialogs/modals
class DialogPage<T> extends Page<T> {
  final WidgetBuilder builder;

  const DialogPage({required this.builder, super.key, super.name, super.arguments});

  @override
  Route<T> createRoute(BuildContext context) {
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
      // theme: // Optional: customize dialog theme
    );
  }
}
