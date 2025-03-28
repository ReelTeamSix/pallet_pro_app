import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Gets the current user.
  User? get currentUser;

  /// Gets the current session.
  Session? get currentSession;

  /// Signs in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Refreshes the current session.
  Future<Session?> refreshSession();

  /// Listens to auth state changes.
  Stream<AuthState> get onAuthStateChange;

  /// Resets the password for the given email.
  Future<void> resetPassword({required String email});
}
