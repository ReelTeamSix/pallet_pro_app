import 'package:json_annotation/json_annotation.dart';

part 'user_settings.g.dart';

/// Enum for cost allocation methods
enum CostAllocationMethod {
  @JsonValue('average')
  average,
  @JsonValue('fifo')
  fifo,
  @JsonValue('lifo')
  lifo,
  @JsonValue('specific')
  specific
}

/// Model representing user settings
@JsonSerializable()
class UserSettings {
  @JsonKey(name: 'id')
  final String userId;
  
  @JsonKey(name: 'has_completed_onboarding')
  final bool hasCompletedOnboarding;
  
  final String theme;
  
  @JsonKey(name: 'enable_biometric_unlock')
  final bool useBiometricAuth;
  
  @JsonKey(name: 'enable_pin_unlock')
  final bool usePinAuth;
  
  @JsonKey(name: 'pin_hash')
  final String? pinHash;
  
  @JsonKey(name: 'cost_allocation_method')
  final CostAllocationMethod costAllocationMethod;
  
  @JsonKey(name: 'show_break_even')
  final bool showBreakEvenPrice;
  
  @JsonKey(name: 'stale_threshold_days')
  final int staleThresholdDays;
  
  @JsonKey(name: 'daily_goal')
  final double dailySalesGoal;
  
  @JsonKey(name: 'weekly_goal')
  final double weeklySalesGoal;
  
  @JsonKey(name: 'monthly_goal')
  final double monthlySalesGoal;
  
  @JsonKey(name: 'yearly_goal')
  final double yearlySalesGoal;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserSettings({
    required this.userId,
    this.hasCompletedOnboarding = false,
    this.theme = 'system',
    this.useBiometricAuth = false,
    this.usePinAuth = false,
    this.pinHash,
    this.costAllocationMethod = CostAllocationMethod.average,
    this.showBreakEvenPrice = true,
    this.staleThresholdDays = 90,
    this.dailySalesGoal = 0.0,
    this.weeklySalesGoal = 0.0,
    this.monthlySalesGoal = 0.0,
    this.yearlySalesGoal = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  /// Converts a string to a CostAllocationMethod
  static CostAllocationMethod costAllocationMethodFromString(String value) {
    switch (value.toLowerCase()) {
      case 'average':
        return CostAllocationMethod.average;
      case 'fifo':
        return CostAllocationMethod.fifo;
      case 'lifo':
        return CostAllocationMethod.lifo;
      case 'specific':
        return CostAllocationMethod.specific;
      default:
        return CostAllocationMethod.average;
    }
  }
  
  /// Creates a copy of this UserSettings with the given fields replaced
  UserSettings copyWith({
    String? userId,
    bool? hasCompletedOnboarding,
    String? theme,
    bool? useBiometricAuth,
    bool? usePinAuth,
    String? pinHash,
    CostAllocationMethod? costAllocationMethod,
    bool? showBreakEvenPrice,
    int? staleThresholdDays,
    double? dailySalesGoal,
    double? weeklySalesGoal,
    double? monthlySalesGoal,
    double? yearlySalesGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      theme: theme ?? this.theme,
      useBiometricAuth: useBiometricAuth ?? this.useBiometricAuth,
      usePinAuth: usePinAuth ?? this.usePinAuth,
      pinHash: pinHash ?? this.pinHash,
      costAllocationMethod: costAllocationMethod ?? this.costAllocationMethod,
      showBreakEvenPrice: showBreakEvenPrice ?? this.showBreakEvenPrice,
      staleThresholdDays: staleThresholdDays ?? this.staleThresholdDays,
      dailySalesGoal: dailySalesGoal ?? this.dailySalesGoal,
      weeklySalesGoal: weeklySalesGoal ?? this.weeklySalesGoal,
      monthlySalesGoal: monthlySalesGoal ?? this.monthlySalesGoal,
      yearlySalesGoal: yearlySalesGoal ?? this.yearlySalesGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          hasCompletedOnboarding == other.hasCompletedOnboarding &&
          theme == other.theme &&
          useBiometricAuth == other.useBiometricAuth &&
          usePinAuth == other.usePinAuth &&
          pinHash == other.pinHash &&
          costAllocationMethod == other.costAllocationMethod &&
          showBreakEvenPrice == other.showBreakEvenPrice &&
          staleThresholdDays == other.staleThresholdDays &&
          dailySalesGoal == other.dailySalesGoal &&
          weeklySalesGoal == other.weeklySalesGoal &&
          monthlySalesGoal == other.monthlySalesGoal &&
          yearlySalesGoal == other.yearlySalesGoal;

  @override
  int get hashCode =>
      userId.hashCode ^
      hasCompletedOnboarding.hashCode ^
      theme.hashCode ^
      useBiometricAuth.hashCode ^
      usePinAuth.hashCode ^
      pinHash.hashCode ^
      costAllocationMethod.hashCode ^
      showBreakEvenPrice.hashCode ^
      staleThresholdDays.hashCode ^
      dailySalesGoal.hashCode ^
      weeklySalesGoal.hashCode ^
      monthlySalesGoal.hashCode ^
      yearlySalesGoal.hashCode;
} 