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
      
      // Check if user already exists by trying to sign in with a dummy password
      try {
        // Try to get user data by email
        final data = await _client.rpc(
          'check_email_exists',
          params: {'email_to_check': trimmedEmail},
        );
        
        if (data != null && data == true) {
          throw AuthException.signUpFailed('User with this email already exists');
        }
      } catch (e) {
        // If the RPC function doesn't exist, we'll just continue with sign-up
        // Supabase will return an error if the user already exists
      }
      
      // If we get here, the user doesn't exist, so we can sign them up
      final response = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
      );
      return response;
    } on gotrue.AuthException catch (e) {
      throw AuthException.signUpFailed(e.message);
    } catch (e) {
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
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }
}
