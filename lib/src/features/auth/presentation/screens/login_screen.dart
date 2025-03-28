import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';

/// The login screen.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a new [LoginScreen] instance.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('LoginScreen: Starting sign in process');
      
      // Get credentials
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // Sign in with forced wait
      await ref.read(authControllerProvider.notifier).signInWithEmail(
        email: email,
        password: password,
      );
      
      // Add a short delay to ensure auth state propagation
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Exit early if the widget was disposed during the delay
      if (!mounted) return;
      
      // Verify sign in was successful
      final authState = ref.read(authControllerProvider);
      
      debugPrint('LoginScreen: Auth state after sign in: ${authState.hasValue ? "has value" : "no value"}, '
          'user: ${authState.value?.id ?? "null"}');
      
      if (authState.hasValue && authState.value != null) {
        debugPrint('LoginScreen: Successfully signed in, navigating to home');
        
        if (mounted) {
          // Force navigation directly to home
          context.go('/home');
        }
      } else {
        debugPrint('LoginScreen: Sign in didn\'t produce a valid user');
        // Guard setState with mounted check
        if (mounted) {
          setState(() {
            _isLoading = false; // Ensure loading indicator stops
            _errorMessage = 'Failed to sign in: No valid user returned';
          });
        }
      }
    } catch (e) {
      debugPrint('LoginScreen: Sign in error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e is AppException ? e.message : 'Failed to sign in: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _signIn(),
                ),
                SizedBox(height: context.spacingXl),
                
                // Sign in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.onPrimaryColor,
                          ),
                        )
                      : Text('Sign In'),
                ),
                SizedBox(height: context.spacingMd),
                
                // Sign up link
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => context.pushNamed('signup'),
                  child: Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
