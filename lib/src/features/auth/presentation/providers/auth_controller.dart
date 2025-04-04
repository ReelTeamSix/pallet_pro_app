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

/// Provider to hold the access token during password recovery flow.
final passwordRecoveryTokenProvider = StateProvider<String?>((ref) => null);

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
    final authState = ref.watch(authStateChangesProvider);
    final authEvent = authState.value?.event;
    final session = authState.value?.session;

    debugPrint('AuthController: Rebuilding | Event: $authEvent | Session: ${session?.accessToken != null ? 'exists' : 'null'}');

    // Handle password recovery specifically
    if (authEvent == AuthChangeEvent.passwordRecovery && session?.accessToken != null) {
      debugPrint('AuthController: Password recovery event detected. Setting token.');
      // Store the access token for the router to pick up
      // Use Future.microtask to avoid modifying state during build
      Future.microtask(() {
         ref.read(passwordRecoveryTokenProvider.notifier).state = session!.accessToken;
      });
      // Do NOT update the main auth state here, let the router handle the redirect
      // Return the PREVIOUS state to avoid premature navigation to home.
      return state.valueOrNull; 
    } 
    // Handle SignedIn event after recovery link was clicked
    // The token should be cleared AFTER navigation to reset screen occurs.
    else if (authEvent == AuthChangeEvent.signedIn && ref.read(passwordRecoveryTokenProvider) != null) {
      debugPrint('AuthController: SignedIn event occurred while recovery token present. Keeping previous state.');
      // Keep the previous state until the router navigates based on the token.
      return state.valueOrNull;
    }
    
    // Default behavior: update state based on the current user from the repository.
    debugPrint('AuthController: Updating state with current user from repository.');
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
      ref.read(isSigningOutProvider.notifier).state = true;
      state = const AsyncValue.loading();
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
      
      ref.read(isSigningOutProvider.notifier).state = false;
      debugPrint('AuthController: Sign out successful');
    } catch (e, stackTrace) {
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

  /// Updates the current user's password.
  Future<void> updatePassword(String newPassword) async {
    debugPrint('AuthController: Updating user password...');
    try {
      // Set explicit loading state
      state = const AsyncValue.loading();

      // Remove the check for state.value == null.
      // Supabase client internally holds the recovery session required for updateUser.
      await _authRepository.updatePassword(newPassword: newPassword);
      
      debugPrint('AuthController: Password updated successfully.');
      
      // Set explicit data state with current user (may be null)
      state = AsyncValue.data(_authRepository.currentUser);
    } catch (e, stackTrace) {
      debugPrint('AuthController: Password update error: $e');
      // Set explicit error state
      state = AsyncValue.error(e, stackTrace);
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
