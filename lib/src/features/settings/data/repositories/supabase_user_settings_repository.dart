import 'package:flutter/foundation.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Implementation of [UserSettingsRepository] using Supabase.
class SupabaseUserSettingsRepository implements UserSettingsRepository {
  /// Creates a new [SupabaseUserSettingsRepository] instance.
  SupabaseUserSettingsRepository({
    required SupabaseClient client,
  }) : _client = client;

  final SupabaseClient _client;
  final String _tableName = 'user_settings';

  @override
  Future<Result<UserSettings?>> getUserSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Result.failure(const AuthException('User not authenticated'));
      }

      try {
        final response = await _client
            .from(_tableName)
            .select()
            .eq('id', user.id)
            .single();

        debugPrint('SupabaseUserSettingsRepository: Raw JSON response: $response');
        return Result.success(UserSettings.fromJson(response));
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // No settings found, create default settings
          debugPrint('No user settings found for user ${user.id}, creating default settings');
          return _createDefaultSettings();
        }
        return Result.failure(DatabaseException('Failed to fetch user settings', e));
      }
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in getUserSettings: ${e.message}, code: ${e.code}');
      if (e.code == 'PGRST116') {
        // No settings found for this user, create default settings
        return _createDefaultSettings();
      }
      return Result.failure(DatabaseException('Failed to fetch user settings', e));
    } catch (e) {
      debugPrint('Exception in getUserSettings: ${e.toString()}');
      
      // If the error is that the user is not authenticated, but we actually have a user
      // in the auth context, try to create default settings
      if (e is AuthException && e.message.contains('not authenticated') && _client.auth.currentUser != null) {
        debugPrint('AuthException but user exists, creating default settings');
        return _createDefaultSettings();
      }
      
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to fetch user settings', e)
      );
    }
  }

  Future<Result<UserSettings>> _createDefaultSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('_createDefaultSettings: No current user');
        return Result.failure(const AuthException('User not authenticated'));
      }

      debugPrint('_createDefaultSettings: Creating settings for user ${user.id}');
      // Create default settings with the correct DB schema field names
      final defaultSettings = {
        'id': user.id,
        'theme': 'system',
        'has_completed_onboarding': false,
        'stale_threshold_days': 30,
        'cost_allocation_method': 'average',
        'enable_biometric_unlock': false,
        'show_break_even': true,
        'daily_goal': 0,
        'weekly_goal': 0,
        'monthly_goal': 0,
        'yearly_goal': 0
      };
      
      debugPrint('_createDefaultSettings: Default settings object: $defaultSettings');
      
      try {
        final response = await _client
            .from(_tableName)
            .insert(defaultSettings)
            .select()
            .single();

        debugPrint('_createDefaultSettings: Created settings successfully');
        return Result.success(UserSettings.fromJson(response));
      } catch (e) {
        debugPrint('_createDefaultSettings: Error creating settings: $e');
        
        // If settings already exist, try to retrieve them
        if (e is PostgrestException && e.code == '23505') {  // Unique constraint violation
          debugPrint('_createDefaultSettings: Settings already exist, retrieving');
          try {
            final response = await _client
                .from(_tableName)
                .select()
                .eq('id', user.id)
                .single();
                
            return Result.success(UserSettings.fromJson(response));
          } catch (retrieveError) {
            return Result.failure(DatabaseException('Failed to retrieve existing settings', retrieveError));
          }
        }
        return Result.failure(DatabaseException('Failed to create default settings', e));
      }
    } catch (e) {
      debugPrint('_createDefaultSettings error: $e');
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to create default settings', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateUserSettings(UserSettings settings) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Result.failure(const AuthException('User not authenticated'));
      }

      if (settings.userId != user.id) {
        return Result.failure(const ValidationException('Cannot update settings for another user'));
      }

      final response = await _client
          .from(_tableName)
          .update(settings.toJson())
          .eq('id', user.id)
          .select()
          .single();

      return Result.success(UserSettings.fromJson(response));
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update user settings', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateHasCompletedOnboarding(bool hasCompleted) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Result.failure(const AuthException('User not authenticated'));
      }
      
      debugPrint('SupabaseUserSettingsRepository: Updating has_completed_onboarding to $hasCompleted');
      
      // First get existing settings to make sure we update with valid data
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      // Update only the has_completed_onboarding field
      final updatedSettings = existingSettings.copyWith(
        hasCompletedOnboarding: hasCompleted
      );
      
      return updateUserSettings(updatedSettings);
    } catch (e) {
      debugPrint('SupabaseUserSettingsRepository: Error updating onboarding status: $e');
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update onboarding status', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateTheme(String theme) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Result.failure(const AuthException('User not authenticated'));
      }

      // Validate theme value
      if (!['light', 'dark', 'system'].contains(theme)) {
        return Result.failure(ValidationException('Invalid theme value: $theme'));
      }

      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(theme: theme);
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update theme setting', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateUseBiometricAuth(bool useBiometricAuth) async {
    try {
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(useBiometricAuth: useBiometricAuth);
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update biometric auth setting', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {
    try {
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(
        usePinAuth: usePinAuth,
        pinHash: pinHash
      );
      
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update PIN settings', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateCostAllocationMethod(CostAllocationMethod method) async {
    try {
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(costAllocationMethod: method);
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update cost allocation method', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    try {
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(showBreakEvenPrice: showBreakEvenPrice);
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update break-even price setting', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateStaleThresholdDays(int days) async {
    try {
      if (days < 1) {
        return Result.failure(ValidationException('Stale threshold days must be at least 1'));
      }

      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(staleThresholdDays: days);
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update stale threshold', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    try {
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      final updatedSettings = existingSettings.copyWith(
        dailySalesGoal: dailyGoal ?? existingSettings.dailySalesGoal,
        weeklySalesGoal: weeklyGoal ?? existingSettings.weeklySalesGoal,
        monthlySalesGoal: monthlyGoal ?? existingSettings.monthlySalesGoal,
        yearlySalesGoal: yearlyGoal ?? existingSettings.yearlySalesGoal,
      );
      
      return updateUserSettings(updatedSettings);
    } catch (e) {
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update sales goals', e)
      );
    }
  }

  @override
  Future<Result<UserSettings>> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return Result.failure(const AuthException('User not authenticated'));
      }

      // Get existing settings first
      final existingSettingsResponse = await getUserSettings();
      if (existingSettingsResponse.isFailure) {
        return Result.failure(existingSettingsResponse.error);
      }
      
      final existingSettings = existingSettingsResponse.value;
      if (existingSettings == null) {
        return Result.failure(const DatabaseException('No existing settings found'));
      }
      
      // Create a new settings object with updates
      final updatedSettings = existingSettings.copyWith(
        hasCompletedOnboarding: true, // Always true after onboarding
        theme: updates['theme'] as String? ?? existingSettings.theme,
        costAllocationMethod: updates['cost_allocation_method'] != null
            ? UserSettings.costAllocationMethodFromString(updates['cost_allocation_method'] as String)
            : existingSettings.costAllocationMethod,
        dailySalesGoal: (updates['daily_goal'] as num?)?.toDouble() ?? existingSettings.dailySalesGoal,
        weeklySalesGoal: (updates['weekly_goal'] as num?)?.toDouble() ?? existingSettings.weeklySalesGoal,
        monthlySalesGoal: (updates['monthly_goal'] as num?)?.toDouble() ?? existingSettings.monthlySalesGoal,
        yearlySalesGoal: (updates['yearly_goal'] as num?)?.toDouble() ?? existingSettings.yearlySalesGoal,
        staleThresholdDays: updates['stale_threshold_days'] as int? ?? existingSettings.staleThresholdDays,
        showBreakEvenPrice: updates['show_break_even'] as bool? ?? existingSettings.showBreakEvenPrice,
        useBiometricAuth: updates['enable_biometric_unlock'] as bool? ?? existingSettings.useBiometricAuth,
        usePinAuth: updates['enable_pin_unlock'] as bool? ?? existingSettings.usePinAuth,
        pinHash: updates['pin_hash'] as String? ?? existingSettings.pinHash,
      );
      
      return updateUserSettings(updatedSettings);
    } catch (e) {
      debugPrint('SupabaseUserSettingsRepository: Error in bulk update: $e');
      return Result.failure(
        e is AppException 
          ? e 
          : DatabaseException('Failed to update settings from onboarding', e)
      );
    }
  }
}
