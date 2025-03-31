import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import '../../../../../test_helpers.dart';

// --- Mocks ---
// Use MockUserSettingsController from test_helpers.dart

// Define a simple test-only implementation of UserSettingsController
class TestUserSettingsController extends UserSettingsController {
  final AsyncValue<UserSettings?> initialState;
  List<bool> onboardingCompletedCalls = [];
  List<Map<String, dynamic>> settingsUpdateCalls = [];
  
  TestUserSettingsController({
    required this.initialState,
  });
  
  @override
  AsyncValue<UserSettings?> get state => initialState;
  
  @override
  Future<UserSettings?> build() async {
    return initialState.valueOrNull;
  }
  
  @override
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {
    onboardingCompletedCalls.add(hasCompleted);
  }
  
  @override
  Future<void> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {
    settingsUpdateCalls.add(updates);
  }
  
  // Stub implementations for other required methods
  @override Future<void> refreshSettings() async {}
  @override Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {}
  @override Future<void> updatePinSettings({required bool usePinAuth, String? pinHash}) async {}
  @override Future<void> updateSalesGoals({double? dailyGoal, double? weeklyGoal, double? monthlyGoal, double? yearlyGoal}) async {}
  @override Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {}
  @override Future<void> updateStaleThresholdDays(int days) async {}
  @override Future<void> updateTheme(String theme) async {}
  @override Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {}
  @override Future<void> updateUserSettings(UserSettings settings) async {}
}

void main() {
  setupTestEnvironment();

  // Helper function to pump the widget
  Future<TestUserSettingsController> pumpOnboardingScreen(WidgetTester tester) async {
    // Create not-onboarded settings
    const userSettings = UserSettings(
      userId: 'mock-user-id',
      hasCompletedOnboarding: false,
      theme: 'system',
      useBiometricAuth: false,
      usePinAuth: false,
      costAllocationMethod: CostAllocationMethod.average,
      showBreakEvenPrice: false,
      staleThresholdDays: 60,
      dailySalesGoal: 100,
      weeklySalesGoal: 700,
      monthlySalesGoal: 3000,
      yearlySalesGoal: 36500,
    );
    
    // Create test controller with not-onboarded state
    final testController = TestUserSettingsController(
      initialState: const AsyncData<UserSettings?>(userSettings),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<UserSettingsController, UserSettings?>(
              () => testController,
            )
          ),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    
    return testController;
  }

  // Helper to advance to next page in onboarding
  Future<void> advanceToNextPage(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('onboardingNextButton')));
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders initial onboarding content and controls', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpOnboardingScreen(tester);

      // Act & Assert
      expect(find.textContaining('Welcome'), findsOneWidget); // Welcome page title
      expect(find.byType(PageView), findsOneWidget); // Verify PageView exists
      expect(find.byKey(const ValueKey('onboardingNextButton')), findsOneWidget); // Next button should be present
      
      // Back button should not be visible on first page
      expect(find.byKey(const ValueKey('onboardingBackButton')), findsNothing);
    });

    testWidgets('Calls updateSettingsFromOnboarding on final step completion', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpOnboardingScreen(tester);

      // Act: Navigate through all pages
      // Page 0 -> 1: Welcome to Goal
      await advanceToNextPage(tester);
      
      // Enter goal value
      await tester.enterText(find.byKey(const ValueKey('dailyGoalField')), '100');
      
      // Page 1 -> 2: Goal to Preferences
      await advanceToNextPage(tester);
      
      // Enter stale threshold
      await tester.enterText(find.byKey(const ValueKey('staleThresholdField')), '30');
      
      // Page 2 -> 3: Preferences to Security
      await advanceToNextPage(tester);
      
      // Page 3 -> 4: Security to Final
      await advanceToNextPage(tester);
      
      // Complete onboarding on final page
      await tester.tap(find.byKey(const ValueKey('onboardingCompleteButton')));
      await tester.pumpAndSettle();

      // Assert: Check that the controller method was called with settings update
      expect(testController.settingsUpdateCalls.length, 1);
    });

    testWidgets('Handles input fields and updates settings', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpOnboardingScreen(tester);

      // Navigate to goals page (page 1)
      await advanceToNextPage(tester);
      
      // Enter goal amount
      await tester.enterText(find.byKey(const ValueKey('dailyGoalField')), '200');
      
      // Navigate to preferences page (page 2)
      await advanceToNextPage(tester);
      
      // Enter stale threshold
      await tester.enterText(find.byKey(const ValueKey('staleThresholdField')), '45');
      
      // Navigate to remaining pages and complete
      await advanceToNextPage(tester); // To security page
      await advanceToNextPage(tester); // To final page
      await tester.tap(find.byKey(const ValueKey('onboardingCompleteButton')));
      await tester.pumpAndSettle();

      // Assert: Check settings were updated correctly
      expect(testController.settingsUpdateCalls.length, 1);
      final updates = testController.settingsUpdateCalls.first;
      
      // Since we entered a goal on the "Weekly" frequency (which is the default)
      expect(updates['weekly_goal'], 200.0);
      expect(updates['stale_threshold_days'], 45);
    });
  });
} 