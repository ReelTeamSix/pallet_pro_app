import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';

import '../../../../../test_helpers.dart';

// --- Mocks ---
// Mock for Biometric Service
class MockBiometricService extends Mock implements BiometricService {}

// Define a simple test-only implementation of UserSettingsController
class TestUserSettingsController extends UserSettingsController {
  TestUserSettingsController({required this.initialState, this.errorToThrow});
  final AsyncValue<UserSettings?> initialState;
  List<bool> onboardingCompletedCalls = [];
  List<Map<String, dynamic>> settingsUpdateCalls = [];
  final Exception? errorToThrow;

  @override
  AsyncValue<UserSettings?> get state => initialState;

  @override
  Future<UserSettings?> build() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return initialState.valueOrNull;
  }

  @override
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {
    onboardingCompletedCalls.add(hasCompleted);
  }

  @override
  Future<void> updateSettingsFromOnboarding(
    Map<String, dynamic> updates,
  ) async {
    settingsUpdateCalls.add(updates);
  }

  // Stub implementations for other required methods
  @override
  Future<void> refreshSettings() async {}
  @override
  Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {}
  @override
  Future<void> updatePinSettings({
    required bool usePinAuth,
    String? pinHash,
  }) async {}
  @override
  Future<void> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {}
  @override
  Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {}
  @override
  Future<void> updateStaleThresholdDays(int days) async {}
  @override
  Future<void> updateTheme(String theme) async {}
  @override
  Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {}
  @override
  Future<void> updateUserSettings(UserSettings settings) async {}
}

void main() {
  setupTestEnvironment();

  // Helper function to pump the widget with necessary providers
  // Return the controller instance for tests to use
  Future<TestUserSettingsController> pumpOnboardingScreen(
    WidgetTester tester,
  ) async {
    final testController = TestUserSettingsController(
      initialState: const AsyncData<UserSettings?>(null),
    );

    // Mock Biometric Service for provider override
    final mockBiometricService = MockBiometricService();
    // Stub isBiometricAvailable to return true by default for testing setup flows
    when(
      mockBiometricService.isBiometricAvailable,
    ).thenAnswer((_) async => true);

    // Define a fixed screen size for tests (Wider to avoid overflow)
    const testScreenSize = Size(800, 800);
    await tester.binding.setSurfaceSize(testScreenSize);
    tester.view.physicalSize = testScreenSize;
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<UserSettingsController, UserSettings?>(
              () => testController,
            ),
          ),
          // Provide the mocked biometric service
          biometricServiceProvider.overrideWithValue(mockBiometricService),
        ],
        child: SizedBox(
          width: testScreenSize.width,
          height: testScreenSize.height,
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/onboarding',
              routes: [
                GoRoute(
                  path: '/onboarding',
                  builder: (context, state) => const OnboardingScreen(),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Scaffold(body: Text('Home')),
                ),
              ],
            ),
            // Add button theme to ensure proper sizing in tests
            theme: ThemeData(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(fixedSize: const Size(200, 48)),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    // Return the controller for tests to access call history etc.
    return testController;
  }

  // Helper to advance to next page in onboarding
  Future<void> advanceToNextPage(WidgetTester tester) async {
    // Find button text rather than the widget type, as it's more reliable in test environment
    final nextButtonFinder = find.text('Next');
    final finishButtonFinder = find.text('Finish Setup');

    // Try for Next button first, then Finish button if we're on the last page
    final buttonFinder = nextButtonFinder.evaluate().isNotEmpty
        ? nextButtonFinder
        : finishButtonFinder;

    expect(
      buttonFinder,
      findsOneWidget,
      reason: 'Could not find Next or Finish Setup button',
    );
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders initial onboarding content and controls', (
      WidgetTester tester,
    ) async {
      // Arrange
      await pumpOnboardingScreen(tester);

      // Act & Assert
      expect(find.textContaining('Welcome'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      // Find Next button by text as verify it is present
      expect(find.text('Next'), findsOneWidget);

      // Back button should not be visible on first page
      expect(find.widgetWithIcon(TextButton, Icons.arrow_back), findsNothing);
    });

    testWidgets('Calls updateSettingsFromOnboarding on final step completion', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testController = await pumpOnboardingScreen(
        tester,
      ); // Get the controller

      // Act: Navigate through all pages
      // Page 0 -> 1: Welcome to Goal
      await advanceToNextPage(tester);

      // Enter goal value - Find by ValueKey which is more reliable
      final goalField = find.byKey(const ValueKey('dailyGoalField'));
      if (goalField.evaluate().isNotEmpty) {
        await tester.enterText(goalField, '100');
      }

      // Page 1 -> 2: Goal to Security (Preferences page was removed)
      await advanceToNextPage(tester);

      // Page 2 -> 3: Security to Final
      await advanceToNextPage(tester);

      // Complete onboarding on final page - Use text finder instead of type finder
      await tester.tap(find.text('Finish Setup'));
      await tester.pumpAndSettle();

      // Assert: Check that the controller method was called with settings update
      expect(testController.settingsUpdateCalls.length, 1);
    });

    testWidgets('Handles input fields and updates settings', (
      WidgetTester tester,
    ) async {
      // Arrange
      final testController = await pumpOnboardingScreen(
        tester,
      ); // Get the controller

      // Navigate to goals page (page 1)
      await advanceToNextPage(tester);

      // Enter goal amount - Find by ValueKey
      final goalField = find.byKey(const ValueKey('dailyGoalField'));
      if (goalField.evaluate().isNotEmpty) {
        await tester.enterText(goalField, '200');
      }

      // Navigate to security page (page 2) - Preferences page was removed
      await advanceToNextPage(tester);

      // Page 3: Security to Final
      await advanceToNextPage(tester);

      // Use text finder instead of PrimaryButton
      await tester.tap(find.text('Finish Setup'));
      await tester.pumpAndSettle();

      // Assert: Check settings were updated correctly
      expect(testController.settingsUpdateCalls.length, 1);
      final updates = testController.settingsUpdateCalls.first;

      // Since we entered a goal on the "Weekly" frequency (which is the default)
      expect(updates['weekly_goal'], 200.0);
      // stale_threshold_days should be the default value (30) since we didn't change it
      expect(updates['stale_threshold_days'], 30);
    });
  });
}
