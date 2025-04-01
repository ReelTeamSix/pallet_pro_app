import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bcrypt/bcrypt.dart'; // For PIN hashing
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
// Import global widgets
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

/// Screen for setting up or changing the user's PIN.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final pin = _pinController.text;

      // Hash the PIN using bcrypt
      // BCrypt.gensalt() uses default rounds (currently 10)
      final String pinHash = BCrypt.hashpw(pin, BCrypt.gensalt());

      // Update user settings via the controller
      await ref.read(userSettingsControllerProvider.notifier).updatePinSettings(
            usePinAuth: true,
            pinHash: pinHash,
          );

      // ALSO enable biometric auth automatically after successful PIN setup
      await ref.read(userSettingsControllerProvider.notifier).updateUseBiometricAuth(true);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back (assuming this screen was pushed from Settings)
      if (context.canPop()) {
         context.pop();
      } else {
        // Fallback navigation if cannot pop (e.g., deep link)
        context.go('/settings');
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is AppException
                ? e.message
                : 'Failed to save PIN: ${e.toString()}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up PIN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a 4-digit PIN to secure your app.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // PIN Input Field
              StyledTextField(
                controller: _pinController,
                labelText: 'New PIN',
                hintText: 'Enter 4 digits',
                prefixIcon: const Icon(Icons.pin),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                maxLength: 4,
                obscureText: _obscurePin,
                textAlign: TextAlign.center,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePin = !_obscurePin;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a PIN';
                  }
                  if (value.length != 4) {
                    return 'PIN must be exactly 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Confirm PIN Input Field
              StyledTextField(
                controller: _confirmPinController,
                labelText: 'Confirm PIN',
                hintText: 'Re-enter 4 digits',
                prefixIcon: const Icon(Icons.pin),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                maxLength: 4,
                obscureText: _obscureConfirmPin,
                textAlign: TextAlign.center,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPin ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPin = !_obscureConfirmPin;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your PIN';
                  }
                  if (value.length != 4) {
                    return 'PIN must be exactly 4 digits';
                  }
                  if (value != _pinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // Save Button
              PrimaryButton(
                text: 'Save PIN',
                onPressed: _isLoading ? null : _savePin,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 