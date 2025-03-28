/// The cost allocation method for items.
enum CostAllocationMethod {
  /// First-in, first-out.
  fifo,
  
  /// Last-in, first-out.
  lifo,
  
  /// Average cost.
  average,
}

/// The user settings model.
class UserSettings {
  /// Creates a new [UserSettings] instance.
  const UserSettings({
    required this.userId,
    this.hasCompletedOnboarding = false,
    this.useDarkMode = false,
    this.useBiometricAuth = false,
    this.costAllocationMethod = CostAllocationMethod.average,
    this.showBreakEvenPrice = true,
    this.staleThresholdDays = 90,
    this.dailySalesGoal = 0,
    this.weeklySalesGoal = 0,
    this.monthlySalesGoal = 0,
    this.yearlySalesGoal = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// The user ID.
  final String userId;
  
  /// Whether the user has completed onboarding.
  final bool hasCompletedOnboarding;
  
  /// Whether to use dark mode.
  final bool useDarkMode;
  
  /// Whether to use biometric authentication.
  final bool useBiometricAuth;
  
  /// The cost allocation method.
  final CostAllocationMethod costAllocationMethod;
  
  /// Whether to show break-even price.
  final bool showBreakEvenPrice;
  
  /// The stale threshold in days.
  final int staleThresholdDays;
  
  /// The daily sales goal.
  final double dailySalesGoal;
  
  /// The weekly sales goal.
  final double weeklySalesGoal;
  
  /// The monthly sales goal.
  final double monthlySalesGoal;
  
  /// The yearly sales goal.
  final double yearlySalesGoal;
  
  /// The created at timestamp.
  final DateTime? createdAt;
  
  /// The updated at timestamp.
  final DateTime? updatedAt;

  /// Creates a new [UserSettings] instance from JSON.
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
      useDarkMode: json['use_dark_mode'] as bool? ?? false,
      useBiometricAuth: json['use_biometric_auth'] as bool? ?? false,
      costAllocationMethod: _costAllocationMethodFromString(json['cost_allocation_method'] as String?),
      showBreakEvenPrice: json['show_break_even_price'] as bool? ?? true,
      staleThresholdDays: json['stale_threshold_days'] as int? ?? 90,
      dailySalesGoal: (json['daily_sales_goal'] as num?)?.toDouble() ?? 0,
      weeklySalesGoal: (json['weekly_sales_goal'] as num?)?.toDouble() ?? 0,
      monthlySalesGoal: (json['monthly_sales_goal'] as num?)?.toDouble() ?? 0,
      yearlySalesGoal: (json['yearly_sales_goal'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [UserSettings] instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'has_completed_onboarding': hasCompletedOnboarding,
      'use_dark_mode': useDarkMode,
      'use_biometric_auth': useBiometricAuth,
      'cost_allocation_method': costAllocationMethod.name,
      'show_break_even_price': showBreakEvenPrice,
      'stale_threshold_days': staleThresholdDays,
      'daily_sales_goal': dailySalesGoal,
      'weekly_sales_goal': weeklySalesGoal,
      'monthly_sales_goal': monthlySalesGoal,
      'yearly_sales_goal': yearlySalesGoal,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [UserSettings] instance with the given fields replaced.
  UserSettings copyWith({
    String? userId,
    bool? hasCompletedOnboarding,
    bool? useDarkMode,
    bool? useBiometricAuth,
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
      useDarkMode: useDarkMode ?? this.useDarkMode,
      useBiometricAuth: useBiometricAuth ?? this.useBiometricAuth,
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

  /// Converts a string to a [CostAllocationMethod].
  static CostAllocationMethod _costAllocationMethodFromString(String? value) {
    switch (value) {
      case 'fifo':
        return CostAllocationMethod.fifo;
      case 'lifo':
        return CostAllocationMethod.lifo;
      case 'average':
      default:
        return CostAllocationMethod.average;
    }
  }
}
