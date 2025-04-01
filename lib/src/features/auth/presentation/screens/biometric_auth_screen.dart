import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart'; // For resetResumeFlag
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
// Import global widgets
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';

/// Screen for handling biometric authentication on app resume.
class BiometricAuthScreen extends ConsumerStatefulWidget {
  /// Callback executed when authentication is successful.
  // final VoidCallback? onAuthenticated; // REMOVED - Logic handled internally

  /// Callback executed when authentication is cancelled or fails.
  // final VoidCallback? onCancel; // REMOVED - Logic handled internally

  /// Indicates why this auth screen is being shown (initial or resume).
  final String? reason;

  const BiometricAuthScreen({super.key, this.reason});

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Attempt authentication immediately when the screen loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Ensure widget is still mounted before starting async operation
        _authenticate();
      }
    });
  }

  Future<void> _authenticate() async {
    // Prevent multiple concurrent authentication attempts
    if (_isAuthenticating) return;

    if (!mounted) return; // Check mount status before setting state
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.authenticate();

      if (!mounted) return; // Check mount status after async operation

      if (success) {
        debugPrint("BiometricAuthScreen: Authentication Successful");
        
        // Mark initial auth as complete in the router *before* navigating or calling callbacks
        ref.read(routerNotifierProvider.notifier).markInitialAuthCompleted();
        
        // widget.onAuthenticated?.call(); // Legacy callback - likely no longer needed
        
        // Explicitly navigate after successful auth, using postFrameCallback for safety
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
             debugPrint("BiometricAuthScreen: Authentication successful, navigating to /home?from=auth_success");
             context.go('/home?from=auth_success');
          }
        });
        
      } else {
        // Although local_auth often throws, handle the false case just in case.
        debugPrint("BiometricAuthScreen: Authentication Failed (returned false)");
        setState(() {
           _errorMessage = "Authentication failed. Please try again.";
           _isAuthenticating = false;
        });
        // Optionally, could call _cancelAuthentication here after a delay
        // or let the user explicitly cancel/retry.
      }
    } catch (e) {
      debugPrint("BiometricAuthScreen: Authentication Error: $e");
      if (!mounted) return; // Check mount status after async error handling

      setState(() {
        // Provide a user-friendly error message
        if (e is PlatformException && e.code == 'LockedOut') {
           _errorMessage = "Too many attempts. Try again later.";
        } else if (e is PlatformException && e.code == 'PermanentlyLockedOut') {
           _errorMessage = "Biometric authentication locked. Please use another method.";
        } else if (e is PlatformException && e.code == 'NotEnrolled') {
           _errorMessage = "No biometrics enrolled on this device.";
        } else if (e is FeatureNotAvailableException) {
            _errorMessage = "Biometric authentication is not available on this device.";
        } else {
           _errorMessage = "An unexpected error occurred. Please try again."; // Generic message
        }
        _isAuthenticating = false;
      });
      // Do not automatically cancel here - let user see the error and retry or cancel.
    }
  }

  // Function to handle cancellation or choosing another method
  void _cancelAuthentication() {
    final isInitialAuth = widget.reason == 'initial_auth';
    debugPrint("BiometricAuthScreen: Cancelled by user (isInitialAuth: $isInitialAuth)");

    if (isInitialAuth) {
      // If cancelling initial required auth, go to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint("BiometricAuthScreen: Initial auth cancelled, navigating to /login?from=cancel_initial");
          context.go('/login?from=cancel_initial');
        }
      });
    } else {
      // If cancelling resume auth, notify router and go home
      ref.read(routerNotifierProvider.notifier).cancelResumeCheck();
    }
  }

  void _navigateToPinAuth() {
      debugPrint("BiometricAuthScreen: Navigating to PIN Auth");
      // We don't want cancelling biometrics to log the user out here
      // Don't call _cancelAuthentication at all - it's causing issues
      
      if (mounted) {
         // Use post-frame callback for reliable navigation
         WidgetsBinding.instance.addPostFrameCallback((_) {
           if (mounted) {
             debugPrint("BiometricAuthScreen: Executing navigation to /pin-auth?from=biometric");
             context.go('/pin-auth?from=biometric');
           }
         });
      }
  }

  // Helper function for signing out and navigating to login
  Future<void> _signOutAndLogin() async {
    if (mounted) {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing out...'),
          duration: Duration(seconds: 1),
        ),
      );
      try {
          // Prepare the router BEFORE signing out
          ref.read(routerNotifierProvider.notifier).prepareForForcedLoginRedirect();
          
          await ref.read(authControllerProvider.notifier).signOut();
          
          // Navigate to login AFTER sign out completes. The router will handle
          // the redirect eventually, but navigating explicitly ensures the user sees 
          // the login screen promptly.
          if (mounted) { // Re-check mounted status after async operation
             debugPrint("BiometricAuthScreen: Navigating to /login after forced sign-out.");
             // Pass 'from=biometric' to help LoginScreen identify the flow
             context.go('/login?from=biometric');
          }
      } catch (e) {
          // If sign out fails, reset the prepared state
          ref.read(routerNotifierProvider.notifier).resetPostAuthTarget();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sign out failed: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch settings to see if PIN is enabled
    final bool pinAuthEnabled = ref.watch(userSettingsControllerProvider
        .select((value) => value.valueOrNull?.usePinAuth ?? false));
        
    return PopScope(
      // Prevent back navigation while authenticating
      canPop: !_isAuthenticating,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final isInitialAuth = widget.reason == 'initial_auth' || widget.reason == 'initial_launch_auth';
        debugPrint("BiometricAuthScreen: Back navigation attempt (isInitialAuth: $isInitialAuth)");

        if (isInitialAuth) {
          debugPrint("BiometricAuthScreen: Back navigation during initial auth, navigating to /login");
          // If cancelling initial auth, don't prepare for forced login
          ref.read(routerNotifierProvider.notifier).resetPostAuthTarget(); 
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
                context.go('/login?from=cancel_initial'); // Explicitly indicate this came from cancelled auth
             }
          });
        } else {
          // For resume auth, back means force sign out to prevent bypass
          debugPrint("BiometricAuthScreen: Back navigation during resume auth, forcing sign out.");
          // Prepare the router BEFORE signing out
          ref.read(routerNotifierProvider.notifier).prepareForForcedLoginRedirect();
          _signOutAndLogin(); // Call sign out (which will navigate to /login)
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unlock Pallet Pro'),
          automaticallyImplyLeading: false, // No back button needed
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 80,
                  color: _errorMessage != null
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  _errorMessage ?? (_isAuthenticating
                      ? 'Authenticating...'
                      : 'Please authenticate to continue'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _errorMessage != null
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                ),
                const SizedBox(height: 32),
                // Show progress indicator when authenticating
                if (_isAuthenticating)
                  const Center(child: CircularProgressIndicator()),
                // Show action buttons when not authenticating or when error occurred
                if (!_isAuthenticating) ...[
                  PrimaryButton(
                    text: 'Retry Authentication',
                    onPressed: _authenticate,
                    // No need for isLoading here as _isAuthenticating controls visibility
                  ),
                  const SizedBox(height: 16),
                  // Show PIN button only if PIN is enabled
                  if (pinAuthEnabled)
                     TextButton.icon(
                        icon: const Icon(Icons.pin),
                        label: const Text('Use PIN Instead'),
                        onPressed: _navigateToPinAuth,
                     ),
                    const SizedBox(height: 8),
                   // Always show Sign Out / Use other method button
                   TextButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out & Use Other Method'),
                      onPressed: _signOutAndLogin, // Sign out and go to login
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                   )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
