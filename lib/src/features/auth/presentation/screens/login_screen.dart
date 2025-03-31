import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/theme/app_icons.dart';
import 'package:pallet_pro_app/src/core/theme/theme_extensions.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException hide UserCredentials;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth show AuthException;

/// The login screen.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a new [LoginScreen] instance.
  const LoginScreen({super.key, this.from});

  /// The source of navigation to this screen.
  final String? from;

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
  void initState() {
    super.initState();
    if (widget.from != null) {
      debugPrint('LoginScreen: Navigated from source: ${widget.from}');
      
      // Immediately check if this is a forced sign-out, and if so, mark the router
      final isFromAuth = widget.from == 'biometric' || 
                       widget.from == 'pin' || 
                       widget.from == 'cancel_initial';
                       
      if (isFromAuth) {
        debugPrint('LoginScreen: Detected auth source in initState, preparing for forced redirect');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(routerNotifierProvider.notifier).prepareForForcedLoginRedirect();
        });
      }
    }
  }

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
      
      // Check if login was from a forced sign-out (biometric/pin auth screens)
      // More comprehensive check for "from" parameter
      final wasFromAuth = widget.from == 'biometric' || 
                        widget.from == 'pin' || 
                        widget.from == 'cancel_initial';
      
      // If this was from a biometric or PIN screen forced sign-out, set the redirect flag
      // This is a safety measure in case the flag was somehow lost during the transitions
      if (wasFromAuth) {
        debugPrint('LoginScreen: Detected login after forced sign-out from ${widget.from}, preparing redirect.');
        ref.read(routerNotifierProvider.notifier).prepareForForcedLoginRedirect();
      } else {
        debugPrint('LoginScreen: Regular sign-in, not from auth screen. From: ${widget.from ?? "null"}');
      }
      
      // Get credentials
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      // Attempt sign in - this will trigger loadings states and redirects
      await ref.read(authControllerProvider.notifier).signInWithEmail(
        email: email,
        password: password,
      );
      
      // After successful sign-in, verify the post auth target is still set
      if (wasFromAuth) {
        final target = ref.read(routerNotifierProvider.notifier).debugGetPostAuthTarget();
        debugPrint('LoginScreen: After successful login, PostAuthTarget = $target');
      } else {
        // For regular sign-in, mark the transition state to handle settings loading
        debugPrint('LoginScreen: Regular sign-in successful, marking transition state');
        ref.read(routerNotifierProvider.notifier).markSignInSuccess();
      }
      
      // DIRECT NAVIGATION APPROACH: Instead of relying on router redirects, 
      // navigate directly to home screen after successful authentication
      if (mounted) {
        debugPrint('LoginScreen: Sign in successful, preparing for direct navigation');
        
        // Ensure user settings are properly loaded before navigation
        try {
          // Force a refresh of user settings
          debugPrint('LoginScreen: Explicitly refreshing user settings before navigation');
          await ref.read(userSettingsControllerProvider.notifier).refreshSettings();
          
          // Small additional delay to ensure everything is synchronized
          await Future.delayed(const Duration(milliseconds: 200));
          
          if (mounted) {
            debugPrint('LoginScreen: Settings refreshed, navigating to dashboard');
            // Use GoRouter's context.go instead of waiting for redirect
            GoRouter.of(context).go('/home?from=direct_login');
          }
        } catch (e) {
          debugPrint('LoginScreen: Error during settings refresh: $e, using fallback navigation');
          // Even if settings refresh fails, still attempt navigation
          if (mounted) {
            // Use a slightly longer delay for fallback navigation
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              GoRouter.of(context).go('/home?from=fallback_navigation');
            }
          }
        }
      }
      
      // The router will automatically handle redirection based on auth state
      debugPrint('LoginScreen: Sign in successful, router will handle redirect.');
      
    } on supabase_auth.AuthException catch (e) {
      debugPrint('LoginScreen: Sign in failed (AuthException): ${e.message}');
      ref.read(routerNotifierProvider.notifier).resetPostAuthTarget(); 
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed: ${e.message}';
        });
      }
    } on AppException catch (e) {
       debugPrint('LoginScreen: Sign in failed (AppException): ${e.message}');
      ref.read(routerNotifierProvider.notifier).resetPostAuthTarget(); 
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      debugPrint('LoginScreen: Sign in error (Unknown): $e');
      // Reset the prepared state if login fails
      ref.read(routerNotifierProvider.notifier).resetPostAuthTarget(); 
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred during sign in.';
        });
      }
    } finally {
      if (mounted && _isLoading) {
        setState(() { _isLoading = false; });
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
                  key: const ValueKey('loginEmailField'),
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
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacingMd),
                
                // Password field
                TextFormField(
                  key: const ValueKey('loginPasswordField'),
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
                SizedBox(height: context.spacingSm),
                
                // Forgot Password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading 
                        ? null 
                        : () {
                            // Navigate to the forgot password screen
                            context.pushNamed('forgot_password'); 
                          },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                SizedBox(height: context.spacingMd),
                
                // Sign in button
                ElevatedButton(
                  key: const ValueKey('loginButton'),
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
