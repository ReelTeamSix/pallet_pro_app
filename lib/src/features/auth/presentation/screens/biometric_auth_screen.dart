import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';

/// Screen for biometric authentication.
class BiometricAuthScreen extends ConsumerStatefulWidget {
  /// Creates a new [BiometricAuthScreen] instance.
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Authenticate on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.authenticate();
      
      if (mounted) {
        if (success) {
          // Authentication successful, navigate to home
          context.go('/home');
        } else {
          setState(() {
            _errorMessage = 'Authentication failed. Please try again.';
            _isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is AppException ? e.message : e.toString();
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is AppException ? e.message : e.toString();
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and title
              Icon(
                AppIcons.pallet,
                size: 80,
                color: context.primaryColor,
              ),
              SizedBox(height: context.spacingMd),
              Text(
                'Pallet Pro',
                style: context.headlineLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingXl),
              
              // Biometric icon
              Icon(
                AppIcons.fingerprint,
                size: 100,
                color: _errorMessage != null
                    ? context.errorColor
                    : context.primaryColor,
              ),
              SizedBox(height: context.spacingLg),
              
              // Status text
              Text(
                _errorMessage ?? 'Authenticate to continue',
                style: context.titleMedium?.copyWith(
                  color: _errorMessage != null ? context.errorColor : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingXl),
              
              // Retry button
              if (_errorMessage != null)
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _authenticate,
                  icon: Icon(AppIcons.retry),
                  label: Text('Try Again'),
                ),
              
              SizedBox(height: context.spacingMd),
              
              // Sign out button
              TextButton(
                onPressed: _isAuthenticating ? null : _signOut,
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
