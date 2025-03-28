import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/auth_repository_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
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
      debugPrint('AuthController: Auth state changed to ${state.event}');
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
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Get the current user to ensure session is valid
      final currentUser = _authRepository.currentUser;
      
      if (currentUser == null) {
        debugPrint('AuthController: User is null after sign in');
        throw const AuthException('Sign in failed: Session not established');
      }
      
      debugPrint('AuthController: Sign in successful for user ${currentUser.id}');
      state = AsyncValue.data(currentUser);
      
      // Try to create or refresh user settings after signing in, with retry
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          debugPrint('AuthController: Ensuring user settings exist (attempt $attempt)');
          await _ensureUserSettingsExist();
          debugPrint('AuthController: User settings ensured successfully');
          break;
        } catch (settingsError) {
          debugPrint('AuthController: Error ensuring settings (attempt $attempt): $settingsError');
          if (attempt == 3) {
            // On last attempt, just continue - we don't want to fail the sign in
            debugPrint('AuthController: Failed to ensure settings after 3 attempts');
          } else {
            // Wait before retry
            await Future.delayed(Duration(milliseconds: 500 * attempt));
          }
        }
      }
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
      
      // Force create user settings for the new user
      if (response.user != null) {
        await _ensureUserSettingsExist();
      }
    } catch (e, stackTrace) {
      debugPrint('AuthController: Sign up error: $e');
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Ensures that user settings exist for the current user.
  Future<void> _ensureUserSettingsExist() async {
    debugPrint('AuthController: Ensuring user settings exist...');
    
    // Wait for authentication to complete
    await Future.delayed(const Duration(seconds: 1));
    
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      debugPrint('AuthController: Cannot create settings - no current user');
      return;
    }

    debugPrint('AuthController: Current user ID: ${currentUser.id}');
    
    // Create user settings directly using the repository
    try {
      // Try to directly create settings in the database
      debugPrint('AuthController: Creating user settings directly...');
      final settingsRepo = ref.read(userSettingsRepositoryProvider);
      
      // Try to get existing settings first
      try {
        debugPrint('AuthController: Checking for existing settings...');
        final existingSettings = await settingsRepo.getUserSettings();
        debugPrint('AuthController: Existing settings found: ${existingSettings.userId}');
        return;
      } catch (e) {
        debugPrint('AuthController: No existing settings: $e');
      }
      
      // Settings don't exist, manually create default settings
      debugPrint('AuthController: Creating new default settings...');
      final defaultSettings = UserSettings(userId: currentUser.id);
      
      try {
        // Save settings to database
        await _createUserSettingsDirectly(defaultSettings);
        debugPrint('AuthController: Settings created successfully');
      } catch (e) {
        debugPrint('AuthController: Error creating settings directly: $e');
        
        // If direct creation fails, try through the controller
        try {
          debugPrint('AuthController: Trying to refresh settings through controller...');
          await ref.read(userSettingsControllerProvider.notifier).refreshSettings();
          debugPrint('AuthController: Settings refreshed successfully');
        } catch (e) {
          debugPrint('AuthController: Error refreshing settings: $e');
        }
      }
    } catch (e) {
      debugPrint('AuthController: Failed to create user settings: $e');
    }
  }
  
  /// Creates user settings directly in the database.
  Future<void> _createUserSettingsDirectly(UserSettings settings) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    
    if (user == null) {
      debugPrint('AuthController: Cannot create settings - not authenticated');
      throw const AuthException('User not authenticated');
    }
    
    debugPrint('AuthController: Inserting settings into database...');
    await client
        .from('user_settings')
        .insert(settings.toJson())
        .select()
        .single();
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    debugPrint('AuthController: Signing out...');
    state = const AsyncValue.loading();
    
    try {
      await _authRepository.signOut();
      debugPrint('AuthController: Sign out successful');
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
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
