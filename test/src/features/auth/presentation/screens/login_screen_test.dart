import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/login_screen.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/routing/app_router.dart';
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../../test_helpers.dart'; // Assuming test_helpers are in root test folder

// --- Mocks ---
// Use MockAuthController from test_helpers.dart
// class MockLoginAuthController extends Mock implements AuthController {} // Removed, use helper mock

class TestRouterNotifier extends RouterNotifier {
  @override
  void build() {
    // No-op implementation to avoid timers
  }
  
  @override
  void resetPostAuthTarget() {
    // No-op implementation
  }
}

// Define a simple test-only implementation of AuthController
class TestAuthController extends AuthController {
  final AsyncValue<supabase.User?> initialState;
  List<({String email, String password})> signInCalls = [];
  List<({String email, String password})> signUpCalls = [];
  List<String> resetPasswordCalls = [];
  List<String> updatePasswordCalls = [];
  Exception? signInException;
  Exception? signUpException;

  TestAuthController({
    required this.initialState,
    this.signInException,
    this.signUpException,
  });

  @override
  Future<supabase.User?> build() async {
    return initialState.valueOrNull;
  }
  
  @override
  AsyncValue<supabase.User?> get state => initialState;

  @override
  Future<void> signUpWithEmail({required String email, required String password}) async {
    signUpCalls.add((email: email, password: password));
    if (signUpException != null) {
      throw signUpException!;
    }
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    signInCalls.add((email: email, password: password));
    if (signInException != null) {
      throw signInException!;
    }
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword({required String email}) async {
    resetPasswordCalls.add(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    updatePasswordCalls.add(newPassword);
  }
  
  @override
  supabase.Session? get currentSession => null;
  
  @override
  Future<supabase.Session?> refreshSession() async => null;
}

void main() {
  setupTestEnvironment();

  // Late variables for mocks
  // Removed: late MockAuthController mockAuthController;

  // Helper function to pump the widget with necessary providers
  Future<TestAuthController> pumpLoginScreen(WidgetTester tester, {Exception? signInError}) async {
    // Create a test controller with a record of sign-in calls
    final testController = TestAuthController(
      initialState: const AsyncData<supabase.User?>(null),
      signInException: signInError,
    );
    
    // Create a test router notifier without timers
    final routerNotifier = TestRouterNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<AuthController, supabase.User?>(
              () => testController,
            )
          ),
          routerNotifierProvider.overrideWith(() => routerNotifier),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    
    return testController;
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('Renders email, password fields and login button', (WidgetTester tester) async {
      // Arrange
      await pumpLoginScreen(tester);

      // Act & Assert
      expect(find.widgetWithText(StyledTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(StyledTextField, 'Password'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.textContaining('Forgot Password?'), findsOneWidget);
      expect(find.textContaining('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('Shows error message for empty email', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpLoginScreen(tester);

      // Act: Tap login button without entering email
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle(); // Allow time for validation and rebuild

      // Assert: Check for email validation error text
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget); // Also check password
      expect(testController.signInCalls.isEmpty, isTrue); // No sign-in calls made
    });

    testWidgets('Shows error message for invalid email format', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpLoginScreen(tester);

      // Act: Enter invalid email and tap login
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), 'password'); // Need valid password for this test
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert: Check for invalid email format error text
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(testController.signInCalls.isEmpty, isTrue); // No sign-in calls made
    });

    testWidgets('Calls signInWithEmail on valid submission', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpLoginScreen(tester);
      
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      // Act: Enter valid credentials and tap login
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), testEmail);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), testPassword);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump(); // Start the process

      // Assert: Verify signInWithEmail was called with correct parameters
      expect(testController.signInCalls.length, 1);
      expect(testController.signInCalls.first.email, testEmail);
      expect(testController.signInCalls.first.password, testPassword);
    });

    testWidgets('Displays error message when signIn fails', (WidgetTester tester) async {
      // Arrange
      const testEmail = 'fail@example.com';
      const testPassword = 'wrongpassword';
      final exception = Exception('Invalid credentials');
      
      // Create a test controller that throws on sign in
      final testController = await pumpLoginScreen(tester, signInError: exception);

      // Act: Enter credentials and tap login
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), testEmail);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), testPassword);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle(); // Let the async operation complete
      
      // Assert: Check for the error message in a Text widget
      expect(find.text('Failed to sign in: Exception: Invalid credentials'), findsOneWidget);
      
      // Complete the test before the timer fires
      await tester.pumpWidget(Container());
    });

    // Add more tests:
    // - Password visibility toggle
    // - Navigation to sign-up screen
    // - Handling loading states correctly
  });
} 