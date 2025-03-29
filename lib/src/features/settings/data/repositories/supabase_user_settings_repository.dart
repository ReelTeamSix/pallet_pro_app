import 'package:flutter/foundation.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
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
  Future<UserSettings> getUserSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', user.id)  // 'id' not 'user_id'
          .single();

      debugPrint('SupabaseUserSettingsRepository: Raw JSON response: $response');

        return UserSettings.fromJson(response);
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // No settings found, create default settings
          debugPrint('No user settings found for user ${user.id}, creating default settings');
          return _createDefaultSettings();
        }
        rethrow;
      }
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException in getUserSettings: ${e.message}, code: ${e.code}');
      if (e.code == 'PGRST116') {
        // No settings found for this user, create default settings
        return _createDefaultSettings();
      }
      throw DatabaseException.fetchFailed('user settings', e.message);
    } catch (e) {
      debugPrint('Exception in getUserSettings: ${e.toString()}');
      
      // If the error is that the user is not authenticated, but we actually have a user
      // in the auth context, try to create default settings
      if (e is AuthException && e.message.contains('not authenticated') && _client.auth.currentUser != null) {
        debugPrint('AuthException but user exists, creating default settings');
        return _createDefaultSettings();
      }
      
      throw DatabaseException.fetchFailed('user settings', e.toString());
    }
  }

  Future<UserSettings> _createDefaultSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('_createDefaultSettings: No current user');
        throw const AuthException('User not authenticated');
      }

      debugPrint('_createDefaultSettings: Creating settings for user ${user.id}');
      // Create default settings with the correct DB schema field names
      final defaultSettings = {
        'id': user.id,
        'theme': 'system',
        'has_completed_onboarding': false,
        'stale_threshold_days': 30,
        'cost_allocation_method': 'even',
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
        return UserSettings.fromJson(response);
      } catch (e) {
        debugPrint('_createDefaultSettings: Error creating settings: $e');
        
        // If settings already exist, try to retrieve them
        if (e is PostgrestException && e.code == '23505') {  // Unique constraint violation
          debugPrint('_createDefaultSettings: Settings already exist, retrieving');
          final response = await _client
              .from(_tableName)
              .select()
              .eq('id', user.id)  // Use 'id' instead of 'user_id'
              .single();
              
          return UserSettings.fromJson(response);
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('_createDefaultSettings error: $e');
      throw DatabaseException.creationFailed('user settings', e.toString());
    }
  }

  @override
  Future<UserSettings> updateUserSettings(UserSettings settings) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      if (settings.userId != user.id) {
        throw const ValidationException('Cannot update settings for another user');
      }

      final response = await _client
          .from(_tableName)
          .update(settings.toJson())
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('user settings', e.toString());
    }
  }

  @override
  Future<UserSettings> updateHasCompletedOnboarding(bool hasCompleted) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }
      
      debugPrint('SupabaseUserSettingsRepository: Updating has_completed_onboarding to $hasCompleted');
      
      // First get existing settings to make sure we update with valid data
      final existingSettings = await _client
          .from(_tableName)
          .select()
          .eq('id', user.id)
          .single();
      
      debugPrint('SupabaseUserSettingsRepository: Existing settings: $existingSettings');
      
      // Update only the has_completed_onboarding field, keeping all other fields as they are
      final response = await _client
          .from(_tableName)
          .update({
            'has_completed_onboarding': hasCompleted,
            // Keep existing values for type-sensitive fields
            'theme': existingSettings['theme'],
            'cost_allocation_method': existingSettings['cost_allocation_method'],
            'daily_goal': existingSettings['daily_goal'],
            'weekly_goal': existingSettings['weekly_goal'],
            'monthly_goal': existingSettings['monthly_goal'],
            'yearly_goal': existingSettings['yearly_goal'],
            'stale_threshold_days': existingSettings['stale_threshold_days'],
            'enable_biometric_unlock': existingSettings['enable_biometric_unlock'],
            'show_break_even': existingSettings['show_break_even'],
          })
          .eq('id', user.id)
          .select()
          .single();
      
      debugPrint('SupabaseUserSettingsRepository: Updated settings successfully');
      return UserSettings.fromJson(response);
    } catch (e) {
      debugPrint('SupabaseUserSettingsRepository: Error updating onboarding status: $e');
      throw DatabaseException.updateFailed('onboarding status', e.toString());
    }
  }

  @override
  Future<UserSettings> updateUseDarkMode(bool useDarkMode) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      // Use 'theme' instead of 'use_dark_mode' and set to 'dark' or 'system'
      final theme = useDarkMode ? 'dark' : 'system';
      
      final response = await _client
          .from(_tableName)
          .update({'theme': theme})
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('dark mode setting', e.toString());
    }
  }

  @override
  Future<UserSettings> updateUseBiometricAuth(bool useBiometricAuth) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .update({'enable_biometric_unlock': useBiometricAuth})  // Use 'enable_biometric_unlock' instead of 'use_biometric_auth'
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('biometric auth setting', e.toString());
    }
  }

  @override
  Future<UserSettings> updateCostAllocationMethod(CostAllocationMethod method) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      // Convert the enum to the string value expected by the database
      String dbValue;
      switch (method) {
        case CostAllocationMethod.fifo:
          dbValue = 'even'; // Map to 'even' in DB
          break;
        case CostAllocationMethod.lifo:
          dbValue = 'proportional'; // Map to 'proportional' in DB
          break;
        case CostAllocationMethod.average:
        default:
          dbValue = 'manual'; // Map to 'manual' in DB
          break;
      }

      final response = await _client
          .from(_tableName)
          .update({'cost_allocation_method': dbValue})
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('cost allocation method', e.toString());
    }
  }

  @override
  Future<UserSettings> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      final response = await _client
          .from(_tableName)
          .update({'show_break_even': showBreakEvenPrice})  // Use 'show_break_even' instead of 'show_break_even_price'
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('break-even price setting', e.toString());
    }
  }

  @override
  Future<UserSettings> updateStaleThresholdDays(int days) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      if (days < 1) {
        throw ValidationException.invalidInput(
          'stale threshold days',
          'Must be at least 1',
        );
      }

      final response = await _client
          .from(_tableName)
          .update({'stale_threshold_days': days})
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('stale threshold', e.toString());
    }
  }

  @override
  Future<UserSettings> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      // Use correct column names as per DB schema
      final updates = <String, dynamic>{};
      if (dailyGoal != null) updates['daily_goal'] = dailyGoal;  // 'daily_goal' instead of 'daily_sales_goal'
      if (weeklyGoal != null) updates['weekly_goal'] = weeklyGoal;  // 'weekly_goal' instead of 'weekly_sales_goal'
      if (monthlyGoal != null) updates['monthly_goal'] = monthlyGoal;  // 'monthly_goal' instead of 'monthly_sales_goal'
      if (yearlyGoal != null) updates['yearly_goal'] = yearlyGoal;  // 'yearly_goal' instead of 'yearly_sales_goal'

      if (updates.isEmpty) {
        // No updates, just return current settings
        return getUserSettings();
      }

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', user.id)  // Use 'id' instead of 'user_id'
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('sales goals', e.toString());
    }
  }

  @override
  Future<UserSettings> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      // Prepare updates using DB column names
      final updates = <String, dynamic>{
        'enable_pin_unlock': usePinAuth,
        'pin_hash': pinHash, // Pass hash directly (can be null to clear it)
      };

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', user.id) // Ensure we update the correct user
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('PIN settings', e.toString());
    }
  }
}
