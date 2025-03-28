import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/auth_repository_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Provider for the [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(() => AuthController());

/// Controller for authentication operations.
class AuthController extends AsyncNotifier<User?> {
  late AuthRepository _authRepository;

  @override
  Future<User?> build() async {
    _authRepository = ref.read(authRepositoryProvider);
    
    // Listen to auth state changes
    _authRepository.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.signedOut ||
          state.event == AuthChangeEvent.userUpdated) {
        ref.invalidateSelf();
      }
    });
    
    return _authRepository.currentUser;
  }

  /// Signs in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw const AuthException('Sign in failed: No user returned');
      }
      
      state = AsyncValue.data(response.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Signs up with email and password.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );
      
      // For email confirmation flow, the user might be null until confirmed
      state = AsyncValue.data(response.user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Resets the password for the given email.
  Future<void> resetPassword({required String email}) async {
    try {
      await _authRepository.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current session.
  Session? get currentSession => _authRepository.currentSession;

  /// Refreshes the current session.
  Future<Session?> refreshSession() async {
    try {
      return await _authRepository.refreshSession();
    } catch (e) {
      rethrow;
    }
  }
}
