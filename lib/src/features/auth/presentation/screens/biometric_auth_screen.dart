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
          await ref.read(authControllerProvider.notifier).signOut();
          // Router will handle redirect to login
      } catch (e) {
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
      // Prevent back navigation while authenticating or if locked out
      canPop: !_isAuthenticating,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If pop was prevented, treat it as cancellation
        _cancelAuthentication();
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
                // Show Retry button if there was an error
                if (_errorMessage != null)
                  ElevatedButton.icon(
                     icon: const Icon(Icons.refresh),
                     label: const Text('Retry'),
                     onPressed: _authenticate, // Re-run the authentication process
                     style: ElevatedButton.styleFrom(
                       foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                       backgroundColor: Theme.of(context).colorScheme.errorContainer,
                     ),
                  ),
                const SizedBox(height: 16),
                // Show Cancel button OR Use PIN button
                if (!_isAuthenticating || _errorMessage != null) ...[
                  // Option 1: Use PIN (if enabled)
                  if (pinAuthEnabled)
                     TextButton(
                      onPressed: _navigateToPinAuth,
                      child: const Text('Use PIN Instead'),
                    ),
                  
                  // Option 2: Cancel OR Sign Out button
                  TextButton(
                    // If PIN is enabled, this is just a 'Cancel'.
                    // If PIN is disabled, this becomes the 'Sign Out' fallback.
                    onPressed: () {
                      if (pinAuthEnabled) {
                        _cancelAuthentication(); // Normal cancel (goes back or to home)
                      } else {
                        // Explicitly sign out if PIN is disabled
                        _signOutAndLogin(); // Reuse the sign out logic
                      }
                    },
                    child: Text(pinAuthEnabled ? 'Cancel' : 'Sign Out'), // Updated label
                  ),
                  
                  // Option 3: Always show "Login with Password" as the ultimate fallback
                  const SizedBox(height: 24), // Add some spacing
                  TextButton(
                    onPressed: _signOutAndLogin, // Reuse the sign out logic
                    child: Text(
                      'Login with Password Instead',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary)
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
