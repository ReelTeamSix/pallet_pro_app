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
  const SignupScreen({super.key, this.from});
  
  /// The source of navigation to this screen.
  final String? from;

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
  void initState() {
    super.initState();
    if (widget.from != null) {
      debugPrint('SignupScreen: Navigated from source: ${widget.from}');
    }
  }

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
      // Attempt sign up - this will trigger loading states and redirects
      await ref.read(authControllerProvider.notifier).signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        // Show success message - router will handle redirections
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please check your email to verify your account.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Navigate back to the login screen after successful signup request
        context.goNamed('login', queryParameters: {'from': 'signup_success'});
      }
    } catch (e) {
      debugPrint('SignupScreen: ENTERED CATCH BLOCK for error: $e');
      
      String errorMsg;
      // Check if the error is likely a Supabase AuthException
      // Note: Supabase might wrap exceptions, so checking type directly might fail.
      // Relying on message content is fragile but often necessary if specific codes aren't exposed clearly.
      final errorString = e.toString().toLowerCase();
      
      if (e is AuthException) {
         // Prefer checking specific codes if available, e.g., e.statusCode == '422' or similar
         if (errorString.contains('user already registered') || errorString.contains('duplicate key value violates unique constraint')) {
           errorMsg = 'An account with this email already exists. Please use a different email or try signing in.';
         } else {
           errorMsg = e.message; // Use Supabase's message if available
         }
      } else if (errorString.contains('user already registered') || errorString.contains('duplicate key value violates unique constraint')) {
         // Fallback check on the string if it wasn't an AuthException type
         errorMsg = 'An account with this email already exists. Please use a different email or try signing in.';
      } else if (e is AppException) {
        errorMsg = e.message;
      } else {
        errorMsg = 'An unexpected error occurred during sign up.'; // More generic
        // Consider logging the full e.toString() for diagnostics
        debugPrint('Unhandled signup error: ${e.toString()}');
      }
      
      setState(() {
        _errorMessage = errorMsg;
        debugPrint('SignupScreen: Set _errorMessage to: $errorMsg');
      });
      
      // Keep the SnackBar for immediate feedback as well, or remove if redundant
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
                
                // Error message display
                if (_errorMessage != null) ...[
                  Padding(
                    padding: EdgeInsets.only(bottom: context.spacingMd), // Add padding
                    child: Container(
                      padding: EdgeInsets.all(context.spacingMd),
                      decoration: BoxDecoration(
                        color: context.errorColor.withOpacity(0.1),
                        border: Border.all(color: context.errorColor), // Add border
                        borderRadius: BorderRadius.circular(context.borderRadiusMd),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: context.bodyMedium?.copyWith(color: context.errorColor), // Use theme style
                        textAlign: TextAlign.center, // Center align
                      ),
                    ),
                  ),
                  // SizedBox(height: context.spacingMd), // Remove redundant SizedBox if using Padding
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
                    helperText: 'Must be 8+ chars, include upper, lower, digit.',
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
