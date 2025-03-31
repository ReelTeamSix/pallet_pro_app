import 'package:flutter/foundation.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:gotrue/src/types/auth_exception.dart' as gotrue;

/// Implementation of [AuthRepository] using Supabase.
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a new [SupabaseAuthRepository] instance.
  SupabaseAuthRepository({
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim();
      
      // Check for duplicate users - first try to check if the email already exists
      try {
        // Try calling a custom function to check if email exists
        // If this fails, we'll continue with the signup and let Supabase handle it
        final response = await _client.functions.invoke('check-email-exists', 
          body: {'email': trimmedEmail});
          
        final body = response.data;
        if (body != null && body['exists'] == true) {
          // Email already exists
          throw AuthException.signUpFailed('User already registered');
        }
      } catch (e) {
        // If the function doesn't exist or fails, just continue with signup
        debugPrint('Error checking if email exists: $e');
      }
      
      // If we get here, the user doesn't exist (or we couldn't check), so we can sign them up
      final response = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
        emailRedirectTo: 'io.supabase.palletproapp://login-callback/',
      );
      
      // Handle user already registered error from Supabase
      if (response.session == null && 
          (response.user == null || response.user?.identities?.isEmpty == true)) {
        throw AuthException.signUpFailed('User already registered');
      }
      
      return response;
    } on gotrue.AuthException catch (e) {
      // Explicitly handle the case of a user that already exists
      if (e.message.contains('already registered') || 
          e.message.contains('already in use') ||
          e.message.toLowerCase().contains('user already exists')) {
        throw AuthException.signUpFailed('User already registered');
      }
      throw AuthException.signUpFailed(e.message);
    } catch (e) {
      debugPrint('SignUp error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException.signUpFailed(e.toString());
    }
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return response;
    } on gotrue.AuthException catch (e) {
      throw AuthException.signInFailed(e.message);
    } catch (e) {
      throw AuthException.signInFailed(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on gotrue.AuthException catch (e) {
      throw AuthException.signOutFailed(e.message);
    } catch (e) {
      throw AuthException.signOutFailed(e.toString());
    }
  }

  @override
  Future<Session?> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session;
    } on gotrue.AuthException catch (e) {
      throw AuthException.sessionExpired();
    } catch (e) {
      throw AuthException('Failed to refresh session: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      // Determine the correct redirect URL based on the platform
      final redirectUrl = kIsWeb
          ? 'http://localhost:3000' // Use the standard web URL for testing
          : 'io.supabase.palletproapp://login-callback/'; // Use the custom scheme for mobile
      
      debugPrint('ResetPassword: Using redirect URL: $redirectUrl');

      // Pass the app's deep link scheme as the redirectTo parameter
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectUrl, // Use the determined URL
      );
    } catch (e) {
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    // The user should be authenticated via the recovery link session at this point.
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on gotrue.AuthException catch (e) {
       throw AuthException('Failed to update password: ${e.message}');
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }
}
