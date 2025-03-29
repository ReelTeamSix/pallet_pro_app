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
    this.usePinAuth = false,
    this.pinHash,
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
  
  /// Whether to use PIN authentication.
  final bool usePinAuth;
  
  /// The securely hashed PIN, if set.
  final String? pinHash;
  
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
      // Fix: Use 'id' from database instead of 'user_id'
      userId: json['id'] as String,
      hasCompletedOnboarding: json['has_completed_onboarding'] as bool? ?? false,
      // Fix: Use 'theme' with conversion instead of 'use_dark_mode'
      useDarkMode: _isDarkTheme(json['theme'] as String?),
      // Fix: Use 'enable_biometric_unlock' instead of 'use_biometric_auth'
      useBiometricAuth: json['enable_biometric_unlock'] as bool? ?? false,
      // Add parsing for new PIN fields
      usePinAuth: json['enable_pin_unlock'] as bool? ?? false,
      pinHash: json['pin_hash'] as String?,
      costAllocationMethod: _costAllocationMethodFromString(json['cost_allocation_method'] as String?),
      // Fix: Use 'show_break_even' instead of 'show_break_even_price'
      showBreakEvenPrice: json['show_break_even'] as bool? ?? true,
      staleThresholdDays: json['stale_threshold_days'] as int? ?? 90,
      // Fix: Use 'daily_goal' instead of 'daily_sales_goal'
      dailySalesGoal: (json['daily_goal'] as num?)?.toDouble() ?? 0,
      weeklySalesGoal: (json['weekly_goal'] as num?)?.toDouble() ?? 0,
      monthlySalesGoal: (json['monthly_goal'] as num?)?.toDouble() ?? 0,
      yearlySalesGoal: (json['yearly_goal'] as num?)?.toDouble() ?? 0,
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
      // Fix: Use 'id' for database instead of 'user_id'
      'id': userId,
      'has_completed_onboarding': hasCompletedOnboarding,
      // Fix: Use 'theme' instead of 'use_dark_mode'
      'theme': useDarkMode ? 'dark' : 'system',
      // Fix: Use 'enable_biometric_unlock' instead of 'use_biometric_auth'
      'enable_biometric_unlock': useBiometricAuth,
      // Add serialization for new PIN fields
      'enable_pin_unlock': usePinAuth,
      'pin_hash': pinHash,
      'cost_allocation_method': _dbCostAllocationMethodFromEnum(costAllocationMethod),
      // Fix: Use 'show_break_even' instead of 'show_break_even_price'
      'show_break_even': showBreakEvenPrice,
      'stale_threshold_days': staleThresholdDays,
      // Fix: Use 'daily_goal' instead of 'daily_sales_goal'
      'daily_goal': dailySalesGoal,
      'weekly_goal': weeklySalesGoal,
      'monthly_goal': monthlySalesGoal,
      'yearly_goal': yearlySalesGoal,
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
      useDarkMode: useDarkMode ?? this.useDarkMode,
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

  /// Converts a string to a [CostAllocationMethod].
  static CostAllocationMethod _costAllocationMethodFromString(String? value) {
    switch (value) {
      case 'even':
        return CostAllocationMethod.fifo; // Map DB 'even' to app 'fifo'
      case 'proportional':
        return CostAllocationMethod.lifo; // Map DB 'proportional' to app 'lifo'
      case 'manual':
        return CostAllocationMethod.average; // Map DB 'manual' to app 'average'
      default:
        return CostAllocationMethod.average;
    }
  }

  /// Maps the CostAllocationMethod enum to the DB string value
  static String _dbCostAllocationMethodFromEnum(CostAllocationMethod method) {
    switch (method) {
      case CostAllocationMethod.fifo:
        return 'even'; // Map app 'fifo' to DB 'even'
      case CostAllocationMethod.lifo:
        return 'proportional'; // Map app 'lifo' to DB 'proportional'
      case CostAllocationMethod.average:
        return 'manual'; // Map app 'average' to DB 'manual'
    }
  }
  
  /// Determines if the theme string represents dark mode
  static bool _isDarkTheme(String? theme) {
    return theme == 'dark';
  }
}
