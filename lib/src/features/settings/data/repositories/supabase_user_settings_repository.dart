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

      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', user.id)
          .single();

      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No settings found, create default settings
        return _createDefaultSettings();
      }
      throw DatabaseException.fetchFailed('user settings', e.message);
    } catch (e) {
      throw DatabaseException.fetchFailed('user settings', e.toString());
    }
  }

  Future<UserSettings> _createDefaultSettings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not authenticated');
      }

      final defaultSettings = UserSettings(userId: user.id);
      
      final response = await _client
          .from(_tableName)
          .insert(defaultSettings.toJson())
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
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
          .eq('user_id', user.id)
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

      final response = await _client
          .from(_tableName)
          .update({'has_completed_onboarding': hasCompleted})
          .eq('user_id', user.id)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
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

      final response = await _client
          .from(_tableName)
          .update({'use_dark_mode': useDarkMode})
          .eq('user_id', user.id)
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
          .update({'use_biometric_auth': useBiometricAuth})
          .eq('user_id', user.id)
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

      final response = await _client
          .from(_tableName)
          .update({'cost_allocation_method': method.name})
          .eq('user_id', user.id)
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
          .update({'show_break_even_price': showBreakEvenPrice})
          .eq('user_id', user.id)
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
          .eq('user_id', user.id)
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

      final updates = <String, dynamic>{};
      if (dailyGoal != null) updates['daily_sales_goal'] = dailyGoal;
      if (weeklyGoal != null) updates['weekly_sales_goal'] = weeklyGoal;
      if (monthlyGoal != null) updates['monthly_sales_goal'] = monthlyGoal;
      if (yearlyGoal != null) updates['yearly_sales_goal'] = yearlyGoal;

      if (updates.isEmpty) {
        // No updates, just return current settings
        return getUserSettings();
      }

      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('user_id', user.id)
          .select()
          .single();

      return UserSettings.fromJson(response);
    } catch (e) {
      throw DatabaseException.updateFailed('sales goals', e.toString());
    }
  }
}
