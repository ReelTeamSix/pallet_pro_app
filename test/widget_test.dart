// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_async/fake_async.dart';
import 'package:pallet_pro_app/src/app.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'test_helpers.dart';

// --- Mocks ---
// Reuse MockUser from test_helpers.dart
class MockSession extends Mock implements Session {}
class MockAuthState extends Mock implements AuthState {}
class MockUserSettings extends Mock implements UserSettings {}

// Mock for AuthController to provide state in tests
class MockAuthController extends AsyncNotifier<supabase.User?> implements AuthController {
  @override
  Future<supabase.User?> build() async {
    return null;
  }
  
  // Basic stubs for auth methods - can be extended as needed
  @override
  Future<void> signInWithEmail({required String email, required String password}) async {}
  
  @override
  Future<void> signOut() async {}
  
  @override
  Future<void> signUpWithEmail({required String email, required String password}) async {}
  
  @override
  Future<void> resetPassword({required String email}) async {}
  
  @override
  Future<void> updatePassword(String newPassword) async {}
  
  @override
  Session? get currentSession => null;
  
  @override
  Future<Session?> refreshSession() async => null;
}

// Mock for UserSettingsController to provide a default value
class MockUserSettingsController extends AutoDisposeAsyncNotifier<UserSettings?>
    implements UserSettingsController {
  @override
  Future<UserSettings?> build() async {
    // Create a default UserSettings instance manually
    return const UserSettings(
      userId: 'test-user',
      hasCompletedOnboarding: true,
      theme: 'system',
      useBiometricAuth: false,
      usePinAuth: false,
      costAllocationMethod: CostAllocationMethod.average,
      showBreakEvenPrice: false,
      staleThresholdDays: 60,
      dailySalesGoal: 300,
      weeklySalesGoal: 1500,
      monthlySalesGoal: 6000,
      yearlySalesGoal: 72000,
    );
  }

  // Add empty implementations for all methods required by the interface
  @override
  Future<void> refreshSettings() async {}

  @override
  Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {}

  @override
  Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {}

  @override
  Future<void> updatePinSettings({required bool usePinAuth, String? pinHash}) async {}

  @override
  Future<void> updateSalesGoals({
    double? dailyGoal,
    double? weeklyGoal,
    double? monthlyGoal,
    double? yearlyGoal,
  }) async {}

  @override
  Future<void> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {}

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

// Testing router notifier periodically making requests
class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Test App'),
        ),
      ),
    );
  }
}

// Sample widget that depends on auth state
class AuthDependentWidget extends ConsumerWidget {
  const AuthDependentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    return authState.when(
      data: (user) => user != null 
        ? Text('Welcome, ${user.id}!') 
        : const Text('Please sign in'),
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}

void main() {
  // Use the helper to set up the test environment
  setupTestEnvironment();
  
  // Initialize Supabase ONCE using the helper
  setUpAll(() async {
    await initializeMockSupabase();
  });

  testWidgets('Basic widget rendering works', (WidgetTester tester) async {
    // Use a simpler test case to verify our testing setup works
    await tester.pumpWidget(const TestApp());
    
    // Verify a simple widget renders
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('Auth dependent widget shows sign in message when no user', (WidgetTester tester) async {
    final mockAuthController = MockAuthController();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => mockAuthController),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AuthDependentWidget(),
            ),
          ),
        ),
      ),
    );
    
    // First it should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Complete the future
    mockAuthController.state = const AsyncData(null);
    await tester.pump();
    
    // Now it should show the sign in message
    expect(find.text('Please sign in'), findsOneWidget);
  });

  testWidgets('Auth dependent widget shows welcome message when user is present', (WidgetTester tester) async {
    final mockAuthController = MockAuthController();
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn('test-user-123');
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => mockAuthController),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AuthDependentWidget(),
            ),
          ),
        ),
      ),
    );
    
    // First it should show loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Complete the future with a user
    mockAuthController.state = AsyncData(mockUser);
    await tester.pump();
    
    // Now it should show the welcome message
    expect(find.text('Welcome, test-user-123!'), findsOneWidget);
  });

  // Later we can add more complex tests when the basic one passes
}
