import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
// Import global widgets
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordUpdated = false;

  @override
  void initState() {
    super.initState();
    // Clear the recovery token when this screen is first built
    // Ensures it's not persisted longer than necessary.
    Future.microtask(() {
      final token = ref.read(passwordRecoveryTokenProvider);
      if (token != null) {
        debugPrint('ResetPasswordScreen: Clearing recovery token on init.');
        ref.read(passwordRecoveryTokenProvider.notifier).state = null;
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _passwordUpdated = false;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final newPassword = _passwordController.text;
      
      // Call the AuthController to update the password
      await ref.read(authControllerProvider.notifier).updatePassword(newPassword);
      
      debugPrint('Reset Password: Password update request sent.');
      // Remove simulated delay
      // await Future.delayed(const Duration(seconds: 1)); 
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _passwordUpdated = true; // Show success message and button
        });
        // Optionally show a success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
      }

    } catch (e) {
      debugPrint('Reset Password Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is AppException ? e.message : 'Failed to update password: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        // Prevent going back if password update hasn't happened
        automaticallyImplyLeading: _passwordUpdated, 
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
                if (!_passwordUpdated)
                  Text(
                    'Enter your new password below.',
                    style: context.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                if (_passwordUpdated)
                   Text(
                    'Your password has been successfully updated.',
                    style: context.bodyMedium?.copyWith(color: Colors.green.shade800),
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
                
                // Don't show fields if password updated successfully
                if (!_passwordUpdated) ...[
                  // New Password Field
                  StyledTextField(
                    controller: _passwordController,
                    labelText: 'New Password',
                    prefixIcon: Icon(AppIcons.password),
                    hintText: 'Must be 8+ chars, include upper, lower, digit.',
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      // Check for uppercase letter
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain an uppercase letter';
                      }
                      // Check for lowercase letter
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must contain a lowercase letter';
                      }
                      // Check for digit
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain a digit';
                      }
                      return null;
                    },
                    enabled: !_isLoading,
                  ),
                  SizedBox(height: context.spacingMd),

                  // Confirm Password Field
                  StyledTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(AppIcons.password),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                     enabled: !_isLoading,
                     onFieldSubmitted: (_) => _isLoading ? null : _updatePassword(),
                  ),
                   SizedBox(height: context.spacingXl),
                ],
                
                // Button Area
                if (!_passwordUpdated)
                  PrimaryButton(
                    text: 'Update Password',
                    onPressed: _isLoading ? null : _updatePassword,
                    isLoading: _isLoading,
                  ),
                  
                if (_passwordUpdated)
                   PrimaryButton(
                    text: 'Back to Login',
                    onPressed: () async { // Make async
                      // Sign out the user after successful password reset
                      await ref.read(authControllerProvider.notifier).signOut();
                      // RouterNotifier will likely handle the redirect to login due to sign out,
                      // but explicitly navigate for safety/clarity.
                      if (context.mounted) { 
                          context.go('/login?from=reset_success'); // Add param for clarity
                      }
                    },
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
} 