import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/data/providers/user_settings_repository_provider.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';

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
    
    try {
      return await _userSettingsRepository.getUserSettings();
    } catch (e) {
      // Return null if there's an error (e.g., user not authenticated)
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
    state = const AsyncValue.loading();
    
    try {
      final settings = await _userSettingsRepository.getUserSettings();
      state = AsyncValue.data(settings);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}
