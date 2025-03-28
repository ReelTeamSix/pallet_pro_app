import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

/// The biometric setup screen.
class BiometricSetupScreen extends ConsumerStatefulWidget {
  /// Creates a new [BiometricSetupScreen] instance.
  const BiometricSetupScreen({super.key});

  @override
  ConsumerState<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends ConsumerState<BiometricSetupScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _useBiometricAuth = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final biometricService = BiometricService();
      final isAvailable = await biometricService.isBiometricAvailable();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _enableBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Test biometric authentication
      final biometricService = BiometricService();
      final success = await biometricService.authenticate();
      
      if (success) {
        // Update user settings
        await ref
            .read(userSettingsControllerProvider.notifier)
            .updateUseBiometricAuth(true);
        
        if (mounted) {
          setState(() {
            _useBiometricAuth = true;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Biometric authentication enabled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is AppException
                  ? e.message
                  : 'Failed to enable biometric authentication: ${e.toString()}',
            ),
            backgroundColor: context.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipBiometricSetup() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Setup'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: context.spacingLg),
              Text(
                'Secure Your App',
                style: context.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingMd),
              Text(
                _isBiometricAvailable
                    ? 'Set up biometric authentication to quickly and securely access your app.'
                    : 'Biometric authentication is not available on this device.',
                style: context.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingLg),
              if (_isBiometricAvailable && !_useBiometricAuth)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _enableBiometricAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enable Biometric Authentication'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              if (_useBiometricAuth)
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.check),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.green,
                  ),
                ),
              SizedBox(height: context.spacingMd),
              TextButton(
                onPressed: _isLoading ? null : _skipBiometricSetup,
                child: const Text('Skip for now'),
              ),
              if (!_isBiometricAvailable)
                Padding(
                  padding: EdgeInsets.only(top: context.spacingMd),
                  child: const Text(
                    'You can enable biometric authentication later in Settings if your device supports it.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
