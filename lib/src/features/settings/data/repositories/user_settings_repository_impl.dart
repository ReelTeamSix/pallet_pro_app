import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

class SupabaseUserSettingsRepository implements UserSettingsRepository {
  final SupabaseClient _client;
  final String _userId;

  SupabaseUserSettingsRepository(this._client, this._userId);

  String get _tableName => 'user_settings';

  @override
  Future<UserSettings> getUserSettings() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', _userId)
          .single();

      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      // Log the error (consider using a logging package)
      print('Error fetching user settings: ${e.message}');
      // Handle specific errors (e.g., user settings not found? Create default?)
      if (e.code == 'PGRST116') { // Resource Not Found
        // Perhaps create default settings and return them?
        // For now, rethrow a more specific exception
        throw NotFoundException('User settings not found.');
      }
      throw DatabaseException('Failed to fetch user settings: ${e.message}');
    } catch (e) {
      // Use DatabaseException instead of AppException
      throw DatabaseException('An unexpected error occurred: $e');
    }
  }

  // Helper to perform update operations
  Future<UserSettings> _updateSingleSetting(String column, dynamic value) async {
     try {
      final response = await _client
          .from(_tableName)
          .update({column: value})
          .eq('id', _userId)
          .select()
          .single();
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating $column: ${e.message}');
      throw DatabaseException('Failed to update setting: ${e.message}');
    } catch (e) {
      // Use DatabaseException instead of AppException
      throw DatabaseException('An unexpected error occurred: $e');
    }
  }

 @override
  Future<UserSettings> updateUserSettings(UserSettings settings) async {
     try {
       // Ensure the id in the settings object matches the current user's ID
       final Map<String, dynamic> settingsMap = settings.toJson();
       // The 'id' in the map should already be the user's ID if loaded correctly
       // We rely on the .eq filter below to ensure we only update the correct row.
       if (settingsMap['id'] != _userId) {
         // Optional: Throw an error or log if the ID in the object doesn't match the repo's user ID
         print('Warning: Updating UserSettings where object ID (${settingsMap['id']}) differs from repository user ID ($_userId)');
         // Force the correct ID for the update filter
         // settingsMap['id'] = _userId; // This might mask issues, careful use.
       }

       final response = await _client
           .from(_tableName)
           .update(settingsMap)
           .eq('id', _userId)
           .select()
           .single();

       return UserSettings.fromJson(response);
     } on PostgrestException catch (e) {
       print('Error updating user settings: ${e.message}');
       throw DatabaseException('Failed to update user settings: ${e.message}');
     } catch (e) {
       // Use DatabaseException instead of AppException
       throw DatabaseException('An unexpected error occurred: $e');
     }
  }


  @override
  Future<UserSettings> updateHasCompletedOnboarding(bool hasCompleted) =>
      _updateSingleSetting('has_completed_onboarding', hasCompleted);

  @override
  Future<UserSettings> updateTheme(String theme) =>
      _updateSingleSetting('theme', theme);

  @override
  Future<UserSettings> updateUseBiometricAuth(bool useBiometricAuth) =>
      _updateSingleSetting('use_biometric_auth', useBiometricAuth);

  @override
  Future<UserSettings> updateCostAllocationMethod(CostAllocationMethod method) =>
      _updateSingleSetting('cost_allocation_method', method.name); // Assuming .name for enum/string storage

  @override
  Future<UserSettings> updateShowBreakEvenPrice(bool showBreakEvenPrice) =>
      _updateSingleSetting('show_break_even_price', showBreakEvenPrice);

  @override
  Future<UserSettings> updateStaleThresholdDays(int days) =>
      _updateSingleSetting('stale_threshold_days', days);

  @override
  Future<UserSettings> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    final updates = <String, dynamic>{};
    if (dailyGoal != null) updates['daily_sales_goal'] = dailyGoal;
    if (weeklyGoal != null) updates['weekly_sales_goal'] = weeklyGoal;
    if (monthlyGoal != null) updates['monthly_sales_goal'] = monthlyGoal;
    if (yearlyGoal != null) updates['yearly_sales_goal'] = yearlyGoal;

    if (updates.isEmpty) {
      return getUserSettings(); // No changes to make
    }

    try {
      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', _userId)
          .select()
          .single();
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating sales goals: ${e.message}');
      throw DatabaseException('Failed to update sales goals: ${e.message}');
    } catch (e) {
      // Use DatabaseException instead of AppException
      throw DatabaseException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserSettings> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {
      final updates = <String, dynamic>{
        'use_pin_auth': usePinAuth,
        'pin_hash': usePinAuth ? pinHash : null, // Only store hash if PIN auth is enabled
      };
      try {
      final response = await _client
          .from(_tableName)
          .update(updates)
          .eq('id', _userId)
          .select()
          .single();
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating PIN settings: ${e.message}');
      throw DatabaseException('Failed to update PIN settings: ${e.message}');
    } catch (e) {
      // Use DatabaseException instead of AppException
      throw DatabaseException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserSettings> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {
    // Ensure onboarding is marked as completed
    final finalUpdates = {...updates, 'has_completed_onboarding': true};

    // Remove id if present
    finalUpdates.remove('id');

     try {
      final response = await _client
          .from(_tableName)
          .update(finalUpdates)
          .eq('id', _userId)
          .select()
          .single();
      return UserSettings.fromJson(response);
    } on PostgrestException catch (e) {
      print('Error updating settings from onboarding: ${e.message}');
      throw DatabaseException('Failed to update onboarding settings: ${e.message}');
    } catch (e) {
      // Use DatabaseException instead of AppException
      throw DatabaseException('An unexpected error occurred: $e');
    }
  }
} 