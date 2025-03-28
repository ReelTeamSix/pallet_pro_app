import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide UserSettings;

/// Provider for the [UserSettingsController].
final userSettingsControllerProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettings?>(
        () => UserSettingsController());

/// Controller for user settings operations.
class UserSettingsController extends AsyncNotifier<UserSettings?> {
  late UserSettingsRepository _userSettingsRepository;

  @override
  Future<UserSettings?> build() async {
    _userSettingsRepository = ref.read(userSettingsRepositoryProvider);
    
    // Watch the raw Supabase auth state stream directly.
    // This ensures settings are fetched ONLY when the actual session changes.
    final authState = ref.watch(authStateChangesProvider);
    final session = authState.valueOrNull?.session;
    final currentUser = session?.user;

    if (currentUser != null) {
      debugPrint('UserSettingsController.build: User ${currentUser.id} detected via AuthStateChanges. Fetching settings...');
      try {
        // Add a small delay to ensure auth is fully established before fetching settings
        // This helps prevent race conditions during rapid auth state changes
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Check if the user is still logged in after the delay (prevents unnecessary fetches)
        final latestAuthState = ref.read(authStateChangesProvider);
        final latestUser = latestAuthState.valueOrNull?.session?.user;
        
        if (latestUser?.id != currentUser.id) {
          debugPrint('UserSettingsController.build: User changed during delay, aborting fetch.');
          return null;
        }
        
        // Assuming getUserSettings implicitly uses the current user from Supabase client context
        final settings = await _userSettingsRepository.getUserSettings();
        debugPrint('UserSettingsController.build: Settings fetched for user ${currentUser.id}');
        return settings;
      } catch (e, stackTrace) {
        debugPrint('UserSettingsController.build: Error fetching settings for user ${currentUser.id}: $e');
        // Re-throw the error to put the provider in an error state.
        // Use AsyncError to preserve stack trace if needed by GoRouter.
        throw AsyncError(e, stackTrace);
      }
    } else {
      // No user logged in, return null (no settings)
      debugPrint('UserSettingsController.build: No user detected via AuthStateChanges.');
      return null;
    }
  }

  /// Updates the user settings.
  Future<void> updateUserSettings(UserSettings settings) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateUserSettings(settings);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates whether the user has completed onboarding.
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateHasCompletedOnboarding(hasCompleted);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates whether to use dark mode.
  Future<void> updateUseDarkMode(bool useDarkMode) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateUseDarkMode(useDarkMode);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates whether to use biometric authentication.
  Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateUseBiometricAuth(useBiometricAuth);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates the cost allocation method.
  Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateCostAllocationMethod(method);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates whether to show break-even price.
  Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateShowBreakEvenPrice(showBreakEvenPrice);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates the stale threshold in days.
  Future<void> updateStaleThresholdDays(int days) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateStaleThresholdDays(days);
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Updates the sales goals.
  Future<void> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final updatedSettings = await _userSettingsRepository.updateSalesGoals(
        dailyGoal: dailyGoal,
        weeklyGoal: weeklyGoal,
        monthlyGoal: monthlyGoal,
        yearlyGoal: yearlyGoal,
      );
      state = AsyncValue.data(updatedSettings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Refreshes the user settings.
  Future<void> refreshSettings() async {
    debugPrint('UserSettingsController.refreshSettings: Starting refresh');
    state = const AsyncValue.loading();
    
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('UserSettingsController.refreshSettings: Attempt $attempt');
        final settings = await _userSettingsRepository.getUserSettings();
        state = AsyncValue.data(settings);
        debugPrint('UserSettingsController.refreshSettings: Success on attempt $attempt');
        return;
      } catch (e, stackTrace) {
        debugPrint('UserSettingsController.refreshSettings: Error on attempt $attempt: $e');
        
        if (attempt == 3) {
          // Only set error state and rethrow on the last attempt
          debugPrint('UserSettingsController.refreshSettings: All attempts failed');
          state = AsyncValue.error(e, stackTrace);
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }
}
