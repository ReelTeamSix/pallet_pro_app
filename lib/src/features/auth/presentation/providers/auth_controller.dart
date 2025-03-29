import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/auth_repository_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, UserSettings;

/// Provider that exposes the Supabase auth state change stream.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Provider to track when sign out is in progress
final isSigningOutProvider = StateProvider<bool>((ref) => false);

/// Provider for the [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(() => AuthController());

/// Controller for authentication operations.
class AuthController extends AsyncNotifier<User?> {
  late AuthRepository _authRepository;

  @override
  Future<User?> build() async {
    _authRepository = ref.read(authRepositoryProvider);
    
    // Watch the auth state stream provider.
    // Riverpod will automatically re-run build when the stream emits.
    final authState = ref.watch(authStateChangesProvider);
    
    // When the stream updates (signIn, signOut, etc.), 
    // simply return the latest user status from the repository.
    debugPrint('AuthController: Rebuilding due to auth state change: ${authState.value?.event}');
    return _authRepository.currentUser;
  }

  /// Signs in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('AuthController: Signing in with email...');
    state = const AsyncValue.loading();
    
    try {
      // First, try to clear any previous session
      try {
        await _authRepository.signOut();
        debugPrint('AuthController: Previous session cleared');
      } catch (e) {
        debugPrint('AuthController: No previous session to clear: $e');
      }
      
      // Now attempt to sign in
      final response = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        debugPrint('AuthController: Sign in failed - no user returned');
        throw const AuthException('Sign in failed: No user returned');
      }
      
      // Wait a moment for session to be properly initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get the current user to ensure session is valid
      final currentUser = _authRepository.currentUser;
      
      if (currentUser == null) {
        debugPrint('AuthController: User is null after sign in');
        throw const AuthException('Sign in failed: Session not established');
      }
      
      debugPrint('AuthController: Sign in successful for user ${currentUser.id}');
      state = AsyncValue.data(currentUser);
    } catch (e, stackTrace) {
      debugPrint('AuthController: Sign in error: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Signs up with email and password.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    debugPrint('AuthController: Signing up with email...');
    state = const AsyncValue.loading();
    
    try {
      final response = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
      );
      
      // For email confirmation flow, the user might be null until confirmed
      debugPrint('AuthController: Sign up response received, user: ${response.user?.id}');
      state = AsyncValue.data(response.user);
    } catch (e, stackTrace) {
      debugPrint('AuthController: Sign up error: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    debugPrint('AuthController: Signing out...');
    
    try {
      // Set the signing out flag to true before starting the process
      ref.read(isSigningOutProvider.notifier).state = true;
      
      // Set loading state *before* performing sign out
      state = const AsyncValue.loading();
      
      // Explicit sign out
      await _authRepository.signOut();
      
      // Immediately set state to null to force router redirection
      state = const AsyncValue.data(null);
      
      // Small delay to ensure all cleanup has occurred, not affecting redirection
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Reset the signing out flag after sign out completes
      ref.read(isSigningOutProvider.notifier).state = false;
      
      debugPrint('AuthController: Sign out successful');
    } catch (e, stackTrace) {
      // Reset the signing out flag in case of error
      ref.read(isSigningOutProvider.notifier).state = false;
      
      debugPrint('AuthController: Sign out error: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Resets the password for the given email.
  Future<void> resetPassword({required String email}) async {
    debugPrint('AuthController: Resetting password...');
    try {
      await _authRepository.resetPassword(email: email);
      debugPrint('AuthController: Password reset email sent');
    } catch (e) {
      debugPrint('AuthController: Password reset error: $e');
      rethrow;
    }
  }

  /// Gets the current session.
  Session? get currentSession => _authRepository.currentSession;

  /// Refreshes the current session.
  Future<Session?> refreshSession() async {
    debugPrint('AuthController: Refreshing session...');
    try {
      final session = await _authRepository.refreshSession();
      debugPrint('AuthController: Session refreshed successfully');
      return session;
    } catch (e) {
      debugPrint('AuthController: Session refresh error: $e');
      rethrow;
    }
  }
}
