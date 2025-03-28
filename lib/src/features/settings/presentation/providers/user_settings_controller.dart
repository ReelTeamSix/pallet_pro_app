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
    
    // Watch the auth state to automatically refetch settings on user change
    final authState = ref.watch(authControllerProvider);
    final currentUser = authState.valueOrNull;

    if (currentUser != null) {
      debugPrint('UserSettingsController.build: User ${currentUser.id} logged in. Fetching settings...');
      try {
        // Assuming getUserSettings implicitly uses the current user from Supabase context
        final settings = await _userSettingsRepository.getUserSettings();
        debugPrint('UserSettingsController.build: Settings fetched for user ${currentUser.id}');
        return settings;
      } catch (e, stackTrace) {
        debugPrint('UserSettingsController.build: Error fetching settings for user ${currentUser.id}: $e');
        // Propagate the error to the AsyncNotifier state
        throw AsyncError(e, stackTrace);
      }
    } else {
      // No user logged in, return null (no settings)
      debugPrint('UserSettingsController.build: No user logged in.');
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
