import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';

/// Repository interface for user settings operations.
abstract class UserSettingsRepository {
  /// Gets the user settings for the current user.
  Future<UserSettings> getUserSettings();

  /// Updates the user settings.
  Future<UserSettings> updateUserSettings(UserSettings settings);

  /// Updates whether the user has completed onboarding.
  Future<UserSettings> updateHasCompletedOnboarding(bool hasCompleted);

  /// Updates whether to use dark mode.
  Future<UserSettings> updateUseDarkMode(bool useDarkMode);

  /// Updates whether to use biometric authentication.
  Future<UserSettings> updateUseBiometricAuth(bool useBiometricAuth);

  /// Updates the cost allocation method.
  Future<UserSettings> updateCostAllocationMethod(CostAllocationMethod method);

  /// Updates whether to show break-even price.
  Future<UserSettings> updateShowBreakEvenPrice(bool showBreakEvenPrice);

  /// Updates the stale threshold in days.
  Future<UserSettings> updateStaleThresholdDays(int days);

  /// Updates the sales goals.
  Future<UserSettings> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  });
}
