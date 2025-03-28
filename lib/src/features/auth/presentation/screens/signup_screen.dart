import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';

/// The signup screen.
class SignupScreen extends ConsumerStatefulWidget {
  /// Creates a new [SignupScreen] instance.
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        // Show success message and navigate back to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email to verify your account.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
        context.goNamed('login');
      }
    } catch (e) {
      debugPrint('SignupScreen: Error signing up: $e');
      
      // Handle duplicate user error specifically
      String errorMsg;
      if (e.toString().contains('User already registered')) {
        errorMsg = 'An account with this email already exists. Please use a different email or try signing in.';
      } else if (e is AppException) {
        errorMsg = e.message;
      } else {
        errorMsg = 'Failed to sign up: ${e.toString()}';
      }
      
      setState(() {
        _errorMessage = errorMsg;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
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
        title: const Text('Create Account'),
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
                // Logo and title
                Icon(
                  AppIcons.pallet,
                  size: 60,
                  color: context.primaryColor,
                ),
                SizedBox(height: context.spacingMd),
                Text(
                  'Join Pallet Pro',
                  style: context.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacingXl),
                
                // Error message
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
                    ),
                  ),
                  SizedBox(height: context.spacingMd),
                ],
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(AppIcons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                ),
                SizedBox(height: context.spacingMd),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(AppIcons.password),
                    helperText: 'Password must be at least 8 characters long',
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(AppIcons.password),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _signUp(),
                ),
                SizedBox(height: context.spacingXl),
                
                // Sign up button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.onPrimaryColor,
                          ),
                        )
                      : Text('Create Account'),
                ),
                SizedBox(height: context.spacingMd),
                
                // Sign in link
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => context.goNamed('login'),
                  child: Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
