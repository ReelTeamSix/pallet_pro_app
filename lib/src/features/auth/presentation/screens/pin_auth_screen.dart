import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';

/// Screen for handling PIN authentication on app resume or as fallback.
class PinAuthScreen extends ConsumerStatefulWidget {
  /// Indicates why this auth screen is being shown (initial or resume).
  final String? reason;

  const PinAuthScreen({super.key, this.reason});

  @override
  ConsumerState<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends ConsumerState<PinAuthScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePin = true;
  bool _authenticated = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    final enteredPin = _pinController.text;
    if (enteredPin.length != 4) {
      setState(() {
        _errorMessage = 'Please enter a 4-digit PIN';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the stored hash from user settings
      final settings = ref.read(userSettingsControllerProvider).valueOrNull;
      final storedHash = settings?.pinHash;

      if (storedHash == null || storedHash.isEmpty) {
        // This shouldn't happen if PIN auth is triggered, but handle defensively
        throw Exception('PIN is not set up.');
      }

      // Verify the entered PIN against the stored hash using bcrypt
      final bool success = BCrypt.checkpw(enteredPin, storedHash);

      if (!mounted) return;

      if (success) {
        debugPrint("PinAuthScreen: Authentication Successful");
        
        // Ensure state update happens first
        if (!mounted) return;
        setState(() {
          _authenticated = true;
          _isLoading = false; 
        });
        
        // Mark initial auth as complete in the router *before* navigating
        ref.read(routerNotifierProvider.notifier).markInitialAuthCompleted();
        
        // Navigate to home AFTER state updates and marking auth complete
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
                debugPrint("PinAuthScreen: Authentication successful, navigating to /home?from=auth_success");
                context.go('/home?from=auth_success');
             }
          });
        }
      } else {
        debugPrint("PinAuthScreen: Authentication Failed (Incorrect PIN)");
        // Reset loading state and show error
        setState(() {
          _errorMessage = "Incorrect PIN. Please try again.";
          _pinController.clear(); // Clear input on failure
          _isLoading = false; 
        });
      }
    } catch (e) {
      debugPrint("PinAuthScreen: Verification Error: $e");
      if (!mounted) return;
      // Reset loading state and show error
      setState(() {
        _errorMessage = "An error occurred during PIN verification.";
        _pinController.clear();
        _isLoading = false; 
      });
    } finally {
      // Ensure isLoading is reset even if an unexpected error occurs during verification
      if (mounted && _isLoading) { 
        setState(() { _isLoading = false; });
      }
    }
  }

  // Function to handle cancellation (invoked by user action)
  void _cancelAuthentication() {
    final isInitialAuth = widget.reason == 'initial_auth';
    debugPrint("PinAuthScreen: Cancelled by user (isInitialAuth: $isInitialAuth)");

    if (isInitialAuth) {
      // If cancelling initial required auth, go to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint("PinAuthScreen: Initial auth cancelled, navigating to /login?from=cancel_initial");
          context.go('/login?from=cancel_initial');
        }
      });
    } else {
      // If cancelling resume auth, notify router and go home
      ref.read(routerNotifierProvider.notifier).cancelResumeCheck();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint("PinAuthScreen: Resume auth cancelled, navigating to /home?from=cancel_resume");
          context.go('/home?from=cancel_resume'); 
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve settings to check if PIN is actually set (optional, for UI hints)
    final settingsAsync = ref.watch(userSettingsControllerProvider);
    final pinIsSet = settingsAsync.valueOrNull?.pinHash != null;

    return PopScope(
      canPop: !_isLoading,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _cancelAuthentication();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter PIN'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.pin_outlined,
                  size: 80,
                  color: _errorMessage != null
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter your 4-digit PIN to unlock',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                // PIN Input Field
                TextFormField(
                  controller: _pinController,
                  autofocus: true, // Focus PIN field immediately
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: 'Enter 4 digits',
                    prefixIcon: const Icon(Icons.pin),
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePin = !_obscurePin;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  obscureText: _obscurePin,
                  textAlign: TextAlign.center, // Center PIN input
                  style: const TextStyle(fontSize: 24, letterSpacing: 10), // Larger PIN digits
                  onChanged: (value) {
                    // Clear error message when user starts typing
                    if (_errorMessage != null) {
                      setState(() { 
                        _errorMessage = null; 
                      });
                    }
                    
                    // Automatically attempt verification when 4 digits are entered
                    if (value.length == 4 && !_isLoading) {
                      _verifyPin();
                    }
                  },
                ),
                const SizedBox(height: 32),
                // Verify Button
                ElevatedButton(
                  onPressed: _isLoading || _pinController.text.length != 4 ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Unlock'),
                ),
                const SizedBox(height: 16),
                // Cancel Button
                TextButton(
                  onPressed: _isLoading ? null : _cancelAuthentication,
                  child: const Text('Cancel'),
                ),
                // Hint if PIN isn't set (shouldn't normally be reachable if logic is correct)
                if (!pinIsSet && !_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'PIN not set up.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 