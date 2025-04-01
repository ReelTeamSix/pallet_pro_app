// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
  userId: json['id'] as String,
  hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
  theme: json['theme'] as String? ?? 'system',
  useBiometricAuth: json['enable_biometric_unlock'] as bool? ?? false,
  usePinAuth: json['enable_pin_unlock'] as bool? ?? false,
  pinHash: json['pin_hash'] as String?,
  costAllocationMethod:
      $enumDecodeNullable(
        _$CostAllocationMethodEnumMap,
        json['cost_allocation_method'],
      ) ??
      CostAllocationMethod.average,
  showBreakEvenPrice: json['show_break_even'] as bool? ?? true,
  staleThresholdDays: (json['stale_threshold_days'] as num?)?.toInt() ?? 90,
  dailySalesGoal: (json['daily_goal'] as num?)?.toDouble() ?? 0.0,
  weeklySalesGoal: (json['weekly_goal'] as num?)?.toDouble() ?? 0.0,
  monthlySalesGoal: (json['monthly_goal'] as num?)?.toDouble() ?? 0.0,
  yearlySalesGoal: (json['yearly_goal'] as num?)?.toDouble() ?? 0.0,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'id': instance.userId,
      'has_completed_onboarding': instance.hasCompletedOnboarding,
      'theme': instance.theme,
      'enable_biometric_unlock': instance.useBiometricAuth,
      'enable_pin_unlock': instance.usePinAuth,
      'pin_hash': instance.pinHash,
      'cost_allocation_method':
          _$CostAllocationMethodEnumMap[instance.costAllocationMethod]!,
      'show_break_even': instance.showBreakEvenPrice,
      'stale_threshold_days': instance.staleThresholdDays,
      'daily_goal': instance.dailySalesGoal,
      'weekly_goal': instance.weeklySalesGoal,
      'monthly_goal': instance.monthlySalesGoal,
      'yearly_goal': instance.yearlySalesGoal,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$CostAllocationMethodEnumMap = {
  CostAllocationMethod.average: 'average',
  CostAllocationMethod.fifo: 'fifo',
  CostAllocationMethod.lifo: 'lifo',
  CostAllocationMethod.specific: 'specific',
  CostAllocationMethod.manual: 'manual',
};
