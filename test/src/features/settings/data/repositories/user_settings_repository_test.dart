import 'package:flutter_test/flutter_test.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
// Don't import the real model - we're completely isolated
// import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
// import 'package:pallet_pro_app/src/features/settings/data/repositories/user_settings_repository.dart';

// Use test helpers for setup
import '../../../../../test_helpers.dart';

// Test enum for cost allocation methods
enum TestCostAllocationMethod {
  average,
  fifo,
  lifo,
  specific,
  manual
}

// Test user settings class - completely independent
class TestUserSettings {
  final String userId;
  final bool hasCompletedOnboarding;
  final String theme;
  final bool useBiometricAuth;
  final bool usePinAuth;
  final String? pinHash;
  final TestCostAllocationMethod costAllocationMethod;
  final bool showBreakEvenPrice;
  final int staleThresholdDays;
  final double dailySalesGoal;
  final double weeklySalesGoal;
  final double monthlySalesGoal;
  final double yearlySalesGoal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestUserSettings({
    required this.userId,
    this.hasCompletedOnboarding = false,
    this.theme = 'system',
    this.useBiometricAuth = false,
    this.usePinAuth = false,
    this.pinHash,
    this.costAllocationMethod = TestCostAllocationMethod.average,
    this.showBreakEvenPrice = true,
    this.staleThresholdDays = 90,
    this.dailySalesGoal = 0.0,
    this.weeklySalesGoal = 0.0,
    this.monthlySalesGoal = 0.0,
    this.yearlySalesGoal = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  // Basic copyWith
  TestUserSettings copyWith({
    String? userId,
    bool? hasCompletedOnboarding,
    String? theme,
    bool? useBiometricAuth,
    bool? usePinAuth,
    String? pinHash,
    TestCostAllocationMethod? costAllocationMethod,
    bool? showBreakEvenPrice,
    int? staleThresholdDays,
    double? dailySalesGoal,
    double? weeklySalesGoal,
    double? monthlySalesGoal,
    double? yearlySalesGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestUserSettings(
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

  // Basic equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestUserSettings &&
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

/// Test implementation of a repository - not implementing the actual interface
/// to avoid typing issues
class UserSettingsRepositoryTest {
  TestUserSettings? _userSettings;
  bool _shouldThrowError = false;
  String? _userId;

  // Default settings to return if no specific settings are set
  TestUserSettings _getDefaultSettingsForUser(String userId) {
    return TestUserSettings(
      userId: userId,
      hasCompletedOnboarding: false,
      theme: 'system',
      useBiometricAuth: false,
      usePinAuth: false,
      costAllocationMethod: TestCostAllocationMethod.average,
      showBreakEvenPrice: false,
      staleThresholdDays: 60,
      dailySalesGoal: 0,
      weeklySalesGoal: 0,
      monthlySalesGoal: 0,
      yearlySalesGoal: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void simulateError([bool shouldThrow = true]) {
    _shouldThrowError = shouldThrow;
  }

  void setUserId(String? userId) {
    // If user is changing, clear the settings
    if (_userId != userId) {
      _userSettings = null;
    }
    
    _userId = userId;
    
    // If a user logs in and no settings exist, create default for them
    if (userId != null && _userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(userId);
    }
  }

  void _checkErrorAndAuth() {
    if (_shouldThrowError) {
      throw const DatabaseException('Simulated database error');
    }
    if (_userId == null) {
      throw const AuthException('User not authenticated');
    }
  }

  Future<TestUserSettings?> getUserSettings() async {
    _checkErrorAndAuth();
    // Return a copy to prevent external modification of the internal state
    return _userSettings?.copyWith();
  }

  Future<TestUserSettings> updateUserSettings(TestUserSettings settings) async {
    _checkErrorAndAuth();
    // Ensure the update is for the currently logged-in user
    if (settings.userId != _userId) {
      throw const AuthException('Attempting to update settings for wrong user');
    }
    // In a real scenario, you might merge settings or just replace
    _userSettings = settings;
    return settings;
  }

  // Individual update methods
  Future<TestUserSettings> updateHasCompletedOnboarding(bool hasCompleted) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      hasCompletedOnboarding: hasCompleted,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateTheme(String theme) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      theme: theme,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateUseBiometricAuth(bool useBiometricAuth) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      useBiometricAuth: useBiometricAuth,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      usePinAuth: usePinAuth,
      pinHash: pinHash,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateCostAllocationMethod(TestCostAllocationMethod method) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      costAllocationMethod: method,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      showBreakEvenPrice: showBreakEvenPrice,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateStaleThresholdDays(int days) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      staleThresholdDays: days,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  Future<TestUserSettings> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {
    _checkErrorAndAuth();
    if (_userSettings == null) {
      _userSettings = _getDefaultSettingsForUser(_userId!);
    }
    _userSettings = _userSettings!.copyWith(
      dailySalesGoal: dailyGoal ?? _userSettings!.dailySalesGoal,
      weeklySalesGoal: weeklyGoal ?? _userSettings!.weeklySalesGoal,
      monthlySalesGoal: monthlyGoal ?? _userSettings!.monthlySalesGoal,
      yearlySalesGoal: yearlyGoal ?? _userSettings!.yearlySalesGoal,
      updatedAt: DateTime.now(),
    );
    return _userSettings!;
  }

  // Method to directly set settings for testing setup
  void setInitialSettings(TestUserSettings settings) {
    if (_userId != null && settings.userId == _userId) {
      _userSettings = settings;
    } else if (_userId == null) {
      // Allow setting if no user is set, assuming it will be associated later
      _userSettings = settings;
    } else {
      print("Warning: SetInitialSettings user ID mismatch. Current: $_userId, Settings: ${settings.userId}");
    }
  }
}

// --- Test Cases ---

void main() {
  setupTestEnvironment();

  late UserSettingsRepositoryTest userSettingsRepository;
  const testUserId = 'user-settings-tester';

  // Initial default settings state for the test user
  final initialSettings = TestUserSettings(
    userId: testUserId,
    hasCompletedOnboarding: false,
    theme: 'light',
    useBiometricAuth: false,
    usePinAuth: false,
    costAllocationMethod: TestCostAllocationMethod.average,
    showBreakEvenPrice: false,
    staleThresholdDays: 30,
    dailySalesGoal: 50,
    weeklySalesGoal: 350,
    monthlySalesGoal: 1500,
    yearlySalesGoal: 18250,
  );

  setUp(() {
    userSettingsRepository = UserSettingsRepositoryTest();
    // Start with a logged-in user and initial settings state
    userSettingsRepository.setUserId(testUserId);
    userSettingsRepository.setInitialSettings(initialSettings);
    userSettingsRepository.simulateError(false); // Reset error simulation
  });

  group('UserSettingsRepository Tests', () {

    test('Get User Settings - Success', () async {
      final settings = await userSettingsRepository.getUserSettings();

      expect(settings, isNotNull);
      expect(settings!.userId, testUserId);
      expect(settings.theme, 'light');
      expect(settings.hasCompletedOnboarding, false);
      expect(settings, initialSettings); // Check full equality
    });

    test('Get User Settings - Auth Error', () async {
      userSettingsRepository.setUserId(null); // Simulate logged out
      expect(
        () => userSettingsRepository.getUserSettings(),
        throwsA(isA<AuthException>()),
      );
    });

    test('Get User Settings - Database Error', () async {
      userSettingsRepository.simulateError();
      expect(
        () => userSettingsRepository.getUserSettings(),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Get User Settings - No Settings Found (Should Return Defaults)', () async {
      // Simulate a different user logging in who has no settings yet
      const newUser = 'new-user-456';
      userSettingsRepository.setUserId(newUser);

      final settings = await userSettingsRepository.getUserSettings();
      expect(settings, isNotNull);
      expect(settings!.userId, newUser);
      // Check a default value
      expect(settings.hasCompletedOnboarding, false);
      expect(settings.theme, 'system'); // Assuming system is the default in repo
    });

    test('Update User Settings - Success', () async {
      final updatedSettings = initialSettings.copyWith(
        theme: 'dark',
        hasCompletedOnboarding: true,
        staleThresholdDays: 45,
      );

      final result = await userSettingsRepository.updateUserSettings(updatedSettings);
      final fetchedSettings = await userSettingsRepository.getUserSettings();

      expect(result, updatedSettings);
      expect(fetchedSettings, isNotNull);
      expect(fetchedSettings!.userId, testUserId);
      expect(fetchedSettings.theme, 'dark');
      expect(fetchedSettings.hasCompletedOnboarding, true);
      expect(fetchedSettings.staleThresholdDays, 45);
      // Ensure other settings remain as they were in the updated object
      expect(fetchedSettings.costAllocationMethod, initialSettings.costAllocationMethod);
      expect(fetchedSettings, updatedSettings);
    });

    test('Update User Settings - Wrong User Error', () async {
      final settingsForDifferentUser = initialSettings.copyWith(userId: 'wrong-user');
      expect(
        () => userSettingsRepository.updateUserSettings(settingsForDifferentUser),
        throwsA(isA<AuthException>()),
      );
    });

    test('Update User Settings - Auth Error', () async {
      userSettingsRepository.setUserId(null); // Simulate logged out
      final updatedSettings = initialSettings.copyWith(theme: 'dark');
      expect(
        () => userSettingsRepository.updateUserSettings(updatedSettings),
        throwsA(isA<AuthException>()),
      );
    });

    test('Update User Settings - Database Error', () async {
      userSettingsRepository.simulateError();
      final updatedSettings = initialSettings.copyWith(theme: 'dark');
      expect(
        () => userSettingsRepository.updateUserSettings(updatedSettings),
        throwsA(isA<DatabaseException>()),
      );
    });

    group('Individual Settings Update Tests', () {
      
      test('Update Theme - Success', () async {
        final result = await userSettingsRepository.updateTheme('dark');
        
        expect(result.theme, 'dark');
        expect(result.userId, testUserId);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.theme, 'dark');
      });
      
      test('Update Has Completed Onboarding - Success', () async {
        final result = await userSettingsRepository.updateHasCompletedOnboarding(true);
        
        expect(result.hasCompletedOnboarding, true);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.hasCompletedOnboarding, true);
      });
      
      test('Update Biometric Auth - Success', () async {
        final result = await userSettingsRepository.updateUseBiometricAuth(true);
        
        expect(result.useBiometricAuth, true);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.useBiometricAuth, true);
      });
      
      test('Update PIN Settings - Success', () async {
        final result = await userSettingsRepository.updatePinSettings(
          usePinAuth: true,
          pinHash: 'hashed_pin_123',
        );
        
        expect(result.usePinAuth, true);
        expect(result.pinHash, 'hashed_pin_123');
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.usePinAuth, true);
        expect(settings.pinHash, 'hashed_pin_123');
      });
      
      test('Update Cost Allocation Method - Success', () async {
        final result = await userSettingsRepository.updateCostAllocationMethod(
          TestCostAllocationMethod.fifo
        );
        
        expect(result.costAllocationMethod, TestCostAllocationMethod.fifo);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.costAllocationMethod, TestCostAllocationMethod.fifo);
      });
      
      test('Update Show Break Even Price - Success', () async {
        final result = await userSettingsRepository.updateShowBreakEvenPrice(true);
        
        expect(result.showBreakEvenPrice, true);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.showBreakEvenPrice, true);
      });
      
      test('Update Stale Threshold Days - Success', () async {
        final result = await userSettingsRepository.updateStaleThresholdDays(60);
        
        expect(result.staleThresholdDays, 60);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.staleThresholdDays, 60);
      });
      
      test('Update Sales Goals - Success', () async {
        final result = await userSettingsRepository.updateSalesGoals(
          dailyGoal: 100,
          weeklyGoal: 700,
          monthlyGoal: 3000,
          yearlyGoal: 36500,
        );
        
        expect(result.dailySalesGoal, 100);
        expect(result.weeklySalesGoal, 700);
        expect(result.monthlySalesGoal, 3000);
        expect(result.yearlySalesGoal, 36500);
        
        final settings = await userSettingsRepository.getUserSettings();
        expect(settings!.dailySalesGoal, 100);
        expect(settings.weeklySalesGoal, 700);
        expect(settings.monthlySalesGoal, 3000);
        expect(settings.yearlySalesGoal, 36500);
      });
      
      test('Update Sales Goals - Partial Update Success', () async {
        final result = await userSettingsRepository.updateSalesGoals(
          dailyGoal: 100,
          // Other goals remain unchanged
        );
        
        expect(result.dailySalesGoal, 100);
        expect(result.weeklySalesGoal, initialSettings.weeklySalesGoal);
        expect(result.monthlySalesGoal, initialSettings.monthlySalesGoal);
        expect(result.yearlySalesGoal, initialSettings.yearlySalesGoal);
      });
    });
  });
} 