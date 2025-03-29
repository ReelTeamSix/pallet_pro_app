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
    // Instead of setting to loading, optimize by using AsyncValue.guard
    final currentSettings = state.valueOrNull;
    
    // Use AsyncValue.guard to handle errors while preserving state
    state = await AsyncValue.guard(() async {
      final updatedSettings = await _userSettingsRepository.updateUserSettings(settings);
      // Return combined settings - keep current state values and only update what changed
      return updatedSettings;
    });
  }

  /// Updates whether the user has completed onboarding.
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {
    // Use optimistic updates to avoid full loading state
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        hasCompletedOnboarding: hasCompleted
      );
      
      // Set immediately to optimistic value (bypasses loading state)
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateHasCompletedOnboarding(hasCompleted);
        // Update with server value (usually same as optimistic, but using server value to be safe)
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Also report the error via AsyncValue.error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateHasCompletedOnboarding(hasCompleted);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates whether to use dark mode.
  Future<void> updateUseDarkMode(bool useDarkMode) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        useDarkMode: useDarkMode
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateUseDarkMode(useDarkMode);
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateUseDarkMode(useDarkMode);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates whether to use biometric authentication.
  Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        useBiometricAuth: useBiometricAuth
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateUseBiometricAuth(useBiometricAuth);
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateUseBiometricAuth(useBiometricAuth);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates the PIN authentication settings.
  Future<void> updatePinSettings({required bool usePinAuth, String? pinHash}) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        usePinAuth: usePinAuth,
        pinHash: pinHash,
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background - Needs matching method in repository
        final updatedSettings = await _userSettingsRepository.updatePinSettings(
          usePinAuth: usePinAuth,
          pinHash: pinHash,
        );
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fallback: Should ideally not happen when setting PIN, but handle defensively
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updatePinSettings(
          usePinAuth: usePinAuth,
          pinHash: pinHash,
        );
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates the cost allocation method.
  Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        costAllocationMethod: method
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateCostAllocationMethod(method);
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateCostAllocationMethod(method);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates whether to show break-even price.
  Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        showBreakEvenPrice: showBreakEvenPrice
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateShowBreakEvenPrice(showBreakEvenPrice);
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateShowBreakEvenPrice(showBreakEvenPrice);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates the stale threshold in days.
  Future<void> updateStaleThresholdDays(int days) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        staleThresholdDays: days
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateStaleThresholdDays(days);
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
      state = const AsyncValue.loading();
      try {
        final updatedSettings = await _userSettingsRepository.updateStaleThresholdDays(days);
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
        rethrow;
      }
    }
  }

  /// Updates the sales goals.
  Future<void> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    // Use optimistic updates pattern
    final currentSettings = state.valueOrNull;
    if (currentSettings != null) {
      // Apply optimistic update
      final optimisticSettings = currentSettings.copyWith(
        dailySalesGoal: dailyGoal ?? currentSettings.dailySalesGoal,
        weeklySalesGoal: weeklyGoal ?? currentSettings.weeklySalesGoal,
        monthlySalesGoal: monthlyGoal ?? currentSettings.monthlySalesGoal,
        yearlySalesGoal: yearlyGoal ?? currentSettings.yearlySalesGoal,
      );
      
      // Set immediately to optimistic value
      state = AsyncValue.data(optimisticSettings);
      
      try {
        // Perform update in background
        final updatedSettings = await _userSettingsRepository.updateSalesGoals(
          dailyGoal: dailyGoal,
          weeklyGoal: weeklyGoal,
          monthlyGoal: monthlyGoal,
          yearlyGoal: yearlyGoal,
        );
        // Update with server value
        state = AsyncValue.data(updatedSettings);
      } catch (e, stackTrace) {
        // On error, revert to previous settings
        state = AsyncValue.data(currentSettings);
        // Report error but don't store in state
        final _ = AsyncValue<UserSettings?>.error(e, stackTrace);
        rethrow;
      }
    } else {
      // Fall back to old behavior if no current settings
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
        final settings = await _userSettingsRepository.getUserSettings();
        
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
  bool _areSettingsEqual(UserSettings a, UserSettings b) {
    return a.userId == b.userId &&
           a.hasCompletedOnboarding == b.hasCompletedOnboarding &&
           a.useDarkMode == b.useDarkMode &&
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
