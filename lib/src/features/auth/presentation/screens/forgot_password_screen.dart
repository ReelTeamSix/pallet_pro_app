import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart'; // Assuming this will handle reset logic
import 'package:pallet_pro_app/src/core/theme/app_icons.dart'; 
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
// Import global widgets
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final email = _emailController.text.trim();
      
      // Call the AuthController to send the reset link
      await ref.read(authControllerProvider.notifier).resetPassword(email: email);
      
      debugPrint('Forgot Password: Requesting reset link for $email - Request Sent');
      // Remove simulated delay
      // await Future.delayed(const Duration(seconds: 1)); 

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Show a generic success message regardless of whether the email exists
          // This prevents account enumeration attacks.
          _successMessage = 'If an account exists for $email, a password reset link has been sent.';
          _emailController.clear(); // Clear the field after submission
        });
      }

    } catch (e) {
      debugPrint('Forgot Password Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is AppException ? e.message : 'Failed to send reset link: $e';
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your email address below and we\'ll send you a link to reset your password.',
                  style: context.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingXl),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: EdgeInsets.all(context.spacingMd),
                    decoration: BoxDecoration(
                      color: context.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(context.borderRadiusMd),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: context.errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.spacingMd),
                ],

                // Success Message
                if (_successMessage != null) ...[
                  Container(
                    padding: EdgeInsets.all(context.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1), // Use a success color
                      borderRadius: BorderRadius.circular(context.borderRadiusMd),
                    ),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade800),
                       textAlign: TextAlign.center,
                    ),
                  ),
                   SizedBox(height: context.spacingMd),
                ],

                // Email Field
                StyledTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icon(AppIcons.email),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  enabled: !_isLoading && _successMessage == null, // Disable if loading or success
                   onFieldSubmitted: (_) => _isLoading || _successMessage != null ? null : _sendResetLink(),
                ),
                SizedBox(height: context.spacingXl),

                // Send Reset Link Button
                PrimaryButton(
                  text: 'Send Reset Link',
                  onPressed: _isLoading || _successMessage != null ? null : _sendResetLink,
                  isLoading: _isLoading,
                ),
                 SizedBox(height: context.spacingMd),
                 
                 // Allow user to try again after success
                 if (_successMessage != null && !_isLoading)
                   TextButton(
                     onPressed: () {
                       setState(() {
                         _successMessage = null;
                         _errorMessage = null;
                       });
                     },
                     child: const Text('Try a different email?')
                   ),
                 
                 // Back to Login Button (Optional, AppBar back arrow is primary)
                 // Only show if not in success state
                 if (_successMessage == null)
                   TextButton(
                     onPressed: _isLoading ? null : () => context.pop(),
                     child: const Text('Back to Login'),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 