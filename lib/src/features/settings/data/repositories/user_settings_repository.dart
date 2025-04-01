import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
// Import custom exception/result types if defined (e.g., Either)
// import 'package:pallet_pro_app/src/core/exceptions/custom_exception.dart';
// import 'package:pallet_pro_app/src/core/utils/either.dart'; // Assuming an Either implementation

/// Repository interface for user settings operations.
abstract class UserSettingsRepository {
  /// Fetches the current user's settings.
  ///
  /// Throws [CustomException] or returns specific error type on failure.
  Future<Result<UserSettings?>> getUserSettings(); // Or Future<Either<CustomException, UserSettings?>>

  /// Updates the entire user settings object.
  ///
  /// Returns the updated [UserSettings].
  /// Throws [CustomException] or returns specific error type on failure.
  Future<Result<UserSettings>> updateUserSettings(UserSettings settings); // Or Future<Either<CustomException, UserSettings>>

  /// Updates specific user settings fields individually (more granular updates).
  /// These often correspond to methods in UserSettingsController.
  /// Consider if all these are needed at the repository level or just the bulk update.

  /// Updates whether the user has completed onboarding.
  Future<Result<UserSettings>> updateHasCompletedOnboarding(bool hasCompleted);

  /// Updates the theme setting.
  Future<Result<UserSettings>> updateTheme(String theme);

  /// Updates whether to use biometric authentication.
  Future<Result<UserSettings>> updateUseBiometricAuth(bool useBiometricAuth);

  /// Updates the PIN authentication settings.
  Future<Result<UserSettings>> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  });

  /// Updates the cost allocation method.
  Future<Result<UserSettings>> updateCostAllocationMethod(CostAllocationMethod method);

  /// Updates whether to show break-even price.
  Future<Result<UserSettings>> updateShowBreakEvenPrice(bool showBreakEvenPrice);

  /// Updates the stale threshold in days.
  Future<Result<UserSettings>> updateStaleThresholdDays(int days);

  /// Updates the sales goals.
  Future<Result<UserSettings>> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  });

  /// Updates multiple settings at once, typically used after onboarding.
  /// The map should contain the database column names and their new values.
  /// This method should ensure 'has_completed_onboarding' is set to true.
  Future<Result<UserSettings>> updateSettingsFromOnboarding(Map<String, dynamic> updates);

  // Potentially add methods for listening to real-time settings changes if needed
  // Stream<Result<UserSettings?>> watchUserSettings();
}
