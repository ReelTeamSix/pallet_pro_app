import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/auth/data/providers/biometric_service_provider.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';
import '../../../../../test_helpers.dart';

// --- Mocks ---
// Mock for Biometric Service
class MockBiometricService extends Mock implements BiometricService {}

// Define a simple test-only implementation of UserSettingsController
class TestUserSettingsController extends UserSettingsController {
  final AsyncValue<UserSettings?> initialState;
  List<bool> onboardingCompletedCalls = [];
  List<Map<String, dynamic>> settingsUpdateCalls = [];
  final Exception? errorToThrow;
  
  TestUserSettingsController({
    required this.initialState,
    this.errorToThrow,
  });
  
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

  // Helper function to pump the widget with necessary providers
  // Return the controller instance for tests to use
  Future<TestUserSettingsController> pumpOnboardingScreen(WidgetTester tester) async {
    final testController = TestUserSettingsController(
      initialState: const AsyncData<UserSettings?>(null),
      errorToThrow: null,
    );

    // Mock Biometric Service for provider override
    final mockBiometricService = MockBiometricService();
    // Stub isBiometricAvailable to return true by default for testing setup flows
    when(() => mockBiometricService.isBiometricAvailable()).thenAnswer((_) async => true);

    // Define a fixed screen size for tests
    const testScreenSize = Size(400, 800);
    await tester.binding.setSurfaceSize(testScreenSize);
    tester.view.physicalSize = testScreenSize;
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSettingsControllerProvider.overrideWithProvider(
             AsyncNotifierProvider<UserSettingsController, UserSettings?>(
               () => testController,
             )
          ),
          // Provide the mocked biometric service
          biometricServiceProvider.overrideWithValue(mockBiometricService),
        ],
        child: SizedBox(
          width: testScreenSize.width,
          height: testScreenSize.height,
          child: MaterialApp(
            home: OnboardingScreen(),
            // Add button theme to ensure proper sizing in tests
            theme: ThemeData(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 48),
                ),
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
    final nextButtonFinder = find.text('NEXT');
    final finishButtonFinder = find.text('FINISH SETUP');

    // Try for Next button first, then Finish button if we're on the last page
    final buttonFinder = nextButtonFinder.evaluate().isNotEmpty 
        ? nextButtonFinder 
        : finishButtonFinder;
    
    expect(buttonFinder, findsOneWidget, reason: 'Could not find NEXT or FINISH SETUP button');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  group('OnboardingScreen Widget Tests', () {
    testWidgets('Renders initial onboarding content and controls', (WidgetTester tester) async {
      // Arrange
      await pumpOnboardingScreen(tester);

      // Act & Assert
      expect(find.textContaining('Welcome'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      // Find PrimaryButton instead of by key
      expect(find.byType(PrimaryButton), findsOneWidget);

      // Back button should not be visible on first page
      expect(find.widgetWithIcon(TextButton, Icons.arrow_back), findsNothing);
    });

    testWidgets('Calls updateSettingsFromOnboarding on final step completion', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpOnboardingScreen(tester); // Get the controller

      // Act: Navigate through all pages
      // Page 0 -> 1: Welcome to Goal
      await advanceToNextPage(tester);

      // Enter goal value - Find by type or more specific ancestor if key fails
      await tester.enterText(find.byType(StyledTextField).at(0), '100');

      // Page 1 -> 2: Goal to Preferences
      await advanceToNextPage(tester);

      // Enter stale threshold - Find by type or more specific ancestor
      await tester.enterText(find.byType(StyledTextField).at(0), '30'); // Assuming it's the first on this page

      // Page 2 -> 3: Preferences to Security
      await advanceToNextPage(tester);

      // Page 3 -> 4: Security to Final
      await advanceToNextPage(tester);

      // Complete onboarding on final page - Use text finder instead of type finder
      await tester.tap(find.text('FINISH SETUP')); 
      await tester.pumpAndSettle();

      // Assert: Check that the controller method was called with settings update
      expect(testController.settingsUpdateCalls.length, 1);
    });

    testWidgets('Handles input fields and updates settings', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpOnboardingScreen(tester); // Get the controller

      // Navigate to goals page (page 1)
      await advanceToNextPage(tester);

      // Enter goal amount - Find by type
      await tester.enterText(find.byType(StyledTextField).first, '200');

      // Navigate to preferences page (page 2)
      await advanceToNextPage(tester);

      // Enter stale threshold - Find by type
      await tester.enterText(find.byType(StyledTextField).first, '45'); // Assuming it's the first on this page

      // Navigate to remaining pages and complete
      await advanceToNextPage(tester); // To security page
      await advanceToNextPage(tester); // To final page
      
      // Use text finder instead of PrimaryButton
      await tester.tap(find.text('FINISH SETUP'));
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