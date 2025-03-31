import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/main.dart' as app;
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pallet_pro_app/src/features/home/presentation/screens/home_screen.dart'; 
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// --- Mocks --- 
// It's often necessary to reuse or redefine mocks for integration tests
// Ensure these mocks are compatible with the ones used in unit/widget tests if needed

class MockUser extends Mock implements supabase.User {}
class MockAuthController extends AsyncNotifier<supabase.User?> implements AuthController {
  // Internal state to simulate login
  supabase.User? _currentUser;

  @override
  Future<supabase.User?> build() async {
    // Start unauthenticated
    _currentUser = null;
    return _currentUser;
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    print("MockAuthController: signInWithEmail called"); // Debug print
    // Simulate successful login after a short delay
    state = const AsyncLoading(); // Show loading
    await Future.delayed(const Duration(milliseconds: 50)); 
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn('test-integration-user');
    _currentUser = mockUser; 
    state = AsyncData(_currentUser); // Update state to logged in
    print("MockAuthController: State updated to logged in");
  }

  // Stub other methods as needed, returning defaults or throwing errors if called unexpectedly
  @override Future<void> signOut() async { state = const AsyncData(null); _currentUser = null; }
  @override Future<void> signUpWithEmail({required String email, required String password}) async {} 
  @override Future<void> resetPassword({required String email}) async {}
  @override Future<void> updatePassword(String newPassword) async {}
  @override supabase.Session? get currentSession => null; 
  @override Future<supabase.Session?> refreshSession() async => null;
}

class MockUserSettingsController extends AutoDisposeAsyncNotifier<UserSettings?> implements UserSettingsController {
  @override
  Future<UserSettings?> build() async {
    // Assume user is onboarded for this login test
    print("MockUserSettingsController: Building with onboarded state");
    return const UserSettings(
      userId: 'test-integration-user', // Match the mock user id
      hasCompletedOnboarding: true,
      // Add other default fields as necessary
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
  }

  // Stub methods
  @override Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {}
  @override Future<void> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {} 
  // Add stubs for other methods if necessary 
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

// Helper to pump app with provider overrides
Future<void> pumpApp(WidgetTester tester) async {
  // Create instances of mocks
  final mockAuthController = MockAuthController();
  final mockUserSettingsController = MockUserSettingsController();

  // IMPORTANT: Reset Supabase instance (if initialized globally in main) 
  // This prevents conflicts with mock clients used in unit tests.
  // Supabase.instance = MockSupabaseClient(); // Or a setup that allows overriding
  // If Supabase is initialized in main, this override needs careful handling.
  // For now, we rely on overriding the providers that USE the Supabase client.

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(() => mockAuthController),
        userSettingsControllerProvider.overrideWith(() => mockUserSettingsController),
        // Explicitly override supabaseClientProvider if your controllers/repos depend on it
        // supabaseClientProvider.overrideWithValue(MockSupabaseClient()), 
      ],
      child: app.MyApp(), // Reference your main app widget
    ),
  );
  await tester.pumpAndSettle(); // Ensure initial frame is settled
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Register fallbacks needed for mocks
  setUpAll(() {
    registerFallbackValue(const UserSettings(userId: '', hasCompletedOnboarding: false));
    registerFallbackValue(CostAllocationMethod.average);
  });

  group('Authentication Flow Integration Test', () {
    testWidgets('User can log in and navigate to home screen', (WidgetTester tester) async {
      // Arrange: Pump the app with mocked providers
      await pumpApp(tester);

      // Verify initial state (should be on LoginScreen)
      print("Test: Verifying initial LoginScreen...");
      expect(find.byType(LoginScreen), findsOneWidget, reason: "Should start on LoginScreen");
      expect(find.byType(HomeScreen), findsNothing);

      // Find login widgets
      final emailField = find.byKey(const ValueKey('loginEmailField'));
      final passwordField = find.byKey(const ValueKey('loginPasswordField'));
      final loginButton = find.byKey(const ValueKey('loginButton'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Act: Enter credentials and tap login
      print("Test: Entering credentials...");
      await tester.enterText(emailField, 'integration@test.com');
      await tester.enterText(passwordField, 'password');
      await tester.pumpAndSettle(); // Allow fields to update

      print("Test: Tapping login button...");
      await tester.tap(loginButton);
      
      // IMPORTANT: pumpAndSettle might take time, especially with delays in mocks
      print("Test: Waiting for login and navigation...");
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Increased duration

      // Assert: Verify navigation to HomeScreen
      print("Test: Verifying navigation to HomeScreen...");
      expect(find.byType(LoginScreen), findsNothing, reason: "Should have navigated away from LoginScreen");
      expect(find.byType(HomeScreen), findsOneWidget, reason: "Should be on HomeScreen after login");

      // Optional: Verify some content on the HomeScreen
      // expect(find.textContaining('Welcome'), findsOneWidget); 
    });

    // TODO: Add tests for other flows (signup, logout) if desired
  });
} 