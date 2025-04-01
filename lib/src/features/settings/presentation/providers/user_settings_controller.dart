import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
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
    
    // Check if sign out is in progress
    final isSigningOut = ref.watch(isSigningOutProvider);
    
    // Watch the raw Supabase auth state stream directly.
    // This ensures settings are fetched ONLY when the actual session changes.
    final authState = ref.watch(authStateChangesProvider);
    final session = authState.valueOrNull?.session;
    final currentUser = session?.user;

    // If sign out is in progress, preserve the current settings rather than setting to null
    if (isSigningOut) {
      debugPrint('UserSettingsController.build: Sign out in progress, preserving current settings');
      return state.valueOrNull; // Return current settings to avoid flickering
    }

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
        final result = await _userSettingsRepository.getUserSettings();
        debugPrint('UserSettingsController.build: Settings fetched for user ${currentUser.id}');
        if (result.isSuccess) {
          return result.value;
        } else {
          throw result.error;
        }
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
    // Instead of setting to loading, optimize by using AsyncValue.guard
    final currentSettings = state.valueOrNull;
    
    // Use AsyncValue.guard to handle errors while preserving state
    state = await AsyncValue.guard(() async {
      final result = await _userSettingsRepository.updateUserSettings(settings);
      if (result.isSuccess) {
        return result.value;
      } else {
        throw result.error;
      }
    });
  }

  /// Updates whether the user has completed onboarding.
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {
    await _updateSettingWithOptimisticUpdate<bool>(
      hasCompleted,
      (settings) => settings.hasCompletedOnboarding,
      (settings, value) => settings.copyWith(hasCompletedOnboarding: value),
      (value) => _userSettingsRepository.updateHasCompletedOnboarding(value)
    );
  }

  /// Helper method to update settings using the Result pattern
  Future<void> _updateSettingWithOptimisticUpdate<T>(
    T newValue,
    T Function(UserSettings) getCurrentValue,
    UserSettings Function(UserSettings, T) updateOptimistic,
    Future<Result<UserSettings>> Function(T) performUpdate
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Only update if the value has changed
      if (getCurrentValue(currentSettings) == newValue) {
        debugPrint('_updateSettingWithOptimisticUpdate: Value unchanged, skipping update');
        return;
      }
      
      // Apply optimistic update
      final optimisticSettings = updateOptimistic(currentSettings, newValue);
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final result = await performUpdate(newValue);
        
        if (result.isSuccess) {
          // Update with server value
          state = AsyncValue.data(result.value);
        } else {
          // On error, revert to previous settings and throw
          state = AsyncValue.data(currentSettings);
          throw result.error;
        }
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to standard loading behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final result = await performUpdate(newValue);
        
        if (result.isSuccess) {
          state = AsyncValue.data(result.value);
        } else {
          state = AsyncValue.error(result.error, StackTrace.current);
          throw result.error;
        }
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Helper method to update multiple settings at once using the Result pattern
  Future<void> _updateMultipleSettingsWithOptimisticUpdate(
    UserSettings Function(UserSettings) updateOptimistic,
    Future<Result<UserSettings>> Function() performUpdate
  ) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = updateOptimistic(currentSettings);
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final result = await performUpdate();
        
        if (result.isSuccess) {
          // Update with server value
          state = AsyncValue.data(result.value);
        } else {
          // On error, revert to previous settings and throw
          state = AsyncValue.data(currentSettings);
          throw result.error;
        }
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to standard loading behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final result = await performUpdate();
        
        if (result.isSuccess) {
          state = AsyncValue.data(result.value);
        } else {
          state = AsyncValue.error(result.error, StackTrace.current);
          throw result.error;
        }
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates the theme setting.
  Future<void> updateTheme(String theme) async {
    await _updateSettingWithOptimisticUpdate<String>(
      theme,
      (settings) => settings.theme,
      (settings, value) => settings.copyWith(theme: value),
      (value) => _userSettingsRepository.updateTheme(value)
    );
  }

  /// Updates whether to use biometric authentication.
  Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {
    await _updateSettingWithOptimisticUpdate<bool>(
      useBiometricAuth,
      (settings) => settings.useBiometricAuth,
      (settings, value) => settings.copyWith(useBiometricAuth: value),
      (value) => _userSettingsRepository.updateUseBiometricAuth(value)
    );
  }

  /// Updates the PIN authentication settings.
  Future<void> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {
    await _updateMultipleSettingsWithOptimisticUpdate(
      (settings) => settings.copyWith(
        usePinAuth: usePinAuth,
        pinHash: pinHash,
      ),
      () => _userSettingsRepository.updatePinSettings(
        usePinAuth: usePinAuth,
        pinHash: pinHash,
      )
    );
  }

  /// Updates the cost allocation method.
  Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {
    await _updateSettingWithOptimisticUpdate<CostAllocationMethod>(
      method,
      (settings) => settings.costAllocationMethod,
      (settings, value) => settings.copyWith(costAllocationMethod: value),
      (value) => _userSettingsRepository.updateCostAllocationMethod(value)
    );
  }

  /// Updates whether to show break-even price.
  Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    await _updateSettingWithOptimisticUpdate<bool>(
      showBreakEvenPrice,
      (settings) => settings.showBreakEvenPrice,
      (settings, value) => settings.copyWith(showBreakEvenPrice: value),
      (value) => _userSettingsRepository.updateShowBreakEvenPrice(value)
    );
  }

  /// Updates the stale threshold in days.
  Future<void> updateStaleThresholdDays(int days) async {
    await _updateSettingWithOptimisticUpdate<int>(
      days,
      (settings) => settings.staleThresholdDays,
      (settings, value) => settings.copyWith(staleThresholdDays: value),
      (value) => _userSettingsRepository.updateStaleThresholdDays(value)
    );
  }

  /// Updates the sales goals.
  Future<void> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    await _updateMultipleSettingsWithOptimisticUpdate(
      (settings) => settings.copyWith(
        dailySalesGoal: dailyGoal ?? settings.dailySalesGoal,
        weeklySalesGoal: weeklyGoal ?? settings.weeklySalesGoal,
        monthlySalesGoal: monthlyGoal ?? settings.monthlySalesGoal,
        yearlySalesGoal: yearlyGoal ?? settings.yearlySalesGoal,
      ),
      () => _userSettingsRepository.updateSalesGoals(
        dailyGoal: dailyGoal,
        weeklyGoal: weeklyGoal,
        monthlyGoal: monthlyGoal,
        yearlyGoal: yearlyGoal,
      )
    );
  }

  /// Updates multiple settings from onboarding data.
  Future<void> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {
    await _updateMultipleSettingsWithOptimisticUpdate(
      (settings) => settings.copyWith(
        hasCompletedOnboarding: true, // Always true after onboarding
        theme: updates['theme'] as String? ?? settings.theme,
        costAllocationMethod: updates['cost_allocation_method'] != null
            ? UserSettings.costAllocationMethodFromString(updates['cost_allocation_method'] as String)
            : settings.costAllocationMethod,
        dailySalesGoal: (updates['daily_goal'] as num?)?.toDouble() ?? settings.dailySalesGoal,
        weeklySalesGoal: (updates['weekly_goal'] as num?)?.toDouble() ?? settings.weeklySalesGoal,
        monthlySalesGoal: (updates['monthly_goal'] as num?)?.toDouble() ?? settings.monthlySalesGoal,
        yearlySalesGoal: (updates['yearly_goal'] as num?)?.toDouble() ?? settings.yearlySalesGoal,
        staleThresholdDays: updates['stale_threshold_days'] as int? ?? settings.staleThresholdDays,
        showBreakEvenPrice: updates['show_break_even'] as bool? ?? settings.showBreakEvenPrice,
        useBiometricAuth: updates['enable_biometric_unlock'] as bool? ?? settings.useBiometricAuth,
        usePinAuth: updates['enable_pin_unlock'] as bool? ?? settings.usePinAuth,
        pinHash: updates['pin_hash'] as String? ?? settings.pinHash,
      ),
      () => _userSettingsRepository.updateSettingsFromOnboarding(updates)
    );
  }

  /// Refreshes the user settings.
  Future<void> refreshSettings() async {
    debugPrint('UserSettingsController.refreshSettings: Starting refresh');
    
    // Keep track of current settings to avoid unnecessary loading state
    final currentSettings = state.valueOrNull;
    
    // Only go to loading state if we don't have settings yet
    if (currentSettings == null) {
      state = const AsyncValue.loading();
    }
    
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        debugPrint('UserSettingsController.refreshSettings: Attempt $attempt');
        final settingsResult = await _userSettingsRepository.getUserSettings();
        
        if (settingsResult.isFailure) {
          debugPrint('UserSettingsController.refreshSettings: Error: ${settingsResult.error}');
          throw settingsResult.error;
        }
        
        final settings = settingsResult.value;
        
        // If no settings were returned, keep current state (if any)
        if (settings == null) {
          debugPrint('UserSettingsController.refreshSettings: No settings returned from repository');
          if (currentSettings == null) {
            state = AsyncValue.data(null);
          }
          return;
        }
        
        // Compare with previous settings to minimize state changes
        if (currentSettings == null || !_areSettingsEqual(currentSettings, settings)) {
          debugPrint('UserSettingsController.refreshSettings: Settings changed, updating state');
          state = AsyncValue.data(settings);
        } else {
          debugPrint('UserSettingsController.refreshSettings: Settings unchanged, keeping current state');
        }
        
        debugPrint('UserSettingsController.refreshSettings: Success on attempt $attempt');
        return;
      } catch (e, stackTrace) {
        debugPrint('UserSettingsController.refreshSettings: Error on attempt $attempt: $e');
        
        if (attempt == 3) {
          // Only set error state and rethrow on the last attempt
          // And only if we don't have current settings
          debugPrint('UserSettingsController.refreshSettings: All attempts failed');
          
          if (currentSettings == null) {
            state = AsyncValue.error(e, stackTrace);
          }
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }
  
  /// Helper to compare settings for equality to avoid unnecessary updates
  bool _areSettingsEqual(UserSettings? a, UserSettings b) {
    if (a == null) return false;
    return a.userId == b.userId &&
           a.hasCompletedOnboarding == b.hasCompletedOnboarding &&
           a.theme == b.theme &&
           a.useBiometricAuth == b.useBiometricAuth &&
           a.usePinAuth == b.usePinAuth &&
           a.pinHash == b.pinHash &&
           a.costAllocationMethod == b.costAllocationMethod &&
           a.showBreakEvenPrice == b.showBreakEvenPrice &&
           a.staleThresholdDays == b.staleThresholdDays &&
           a.dailySalesGoal == b.dailySalesGoal &&
           a.weeklySalesGoal == b.weeklySalesGoal &&
           a.monthlySalesGoal == b.monthlySalesGoal &&
           a.yearlySalesGoal == b.yearlySalesGoal;
  }
}
