// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) =>
    _UserSettings(
      userId: json['userId'] as String,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      useDarkMode: json['useDarkMode'] as bool? ?? false,
      useBiometricAuth: json['useBiometricAuth'] as bool? ?? false,
      costAllocationMethod:
          $enumDecodeNullable(
            _$CostAllocationMethodEnumMap,
            json['costAllocationMethod'],
          ) ??
          CostAllocationMethod.average,
      showBreakEvenPrice: json['showBreakEvenPrice'] as bool? ?? true,
      staleThresholdDays: (json['staleThresholdDays'] as num?)?.toInt() ?? 90,
      dailySalesGoal: (json['dailySalesGoal'] as num?)?.toDouble() ?? 0,
      weeklySalesGoal: (json['weeklySalesGoal'] as num?)?.toDouble() ?? 0,
      monthlySalesGoal: (json['monthlySalesGoal'] as num?)?.toDouble() ?? 0,
      yearlySalesGoal: (json['yearlySalesGoal'] as num?)?.toDouble() ?? 0,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserSettingsToJson(_UserSettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'hasCompletedOnboarding': instance.hasCompletedOnboarding,
      'useDarkMode': instance.useDarkMode,
      'useBiometricAuth': instance.useBiometricAuth,
      'costAllocationMethod':
          _$CostAllocationMethodEnumMap[instance.costAllocationMethod]!,
      'showBreakEvenPrice': instance.showBreakEvenPrice,
      'staleThresholdDays': instance.staleThresholdDays,
      'dailySalesGoal': instance.dailySalesGoal,
      'weeklySalesGoal': instance.weeklySalesGoal,
      'monthlySalesGoal': instance.monthlySalesGoal,
      'yearlySalesGoal': instance.yearlySalesGoal,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$CostAllocationMethodEnumMap = {
  CostAllocationMethod.fifo: 'fifo',
  CostAllocationMethod.lifo: 'lifo',
  CostAllocationMethod.average: 'average',
};
