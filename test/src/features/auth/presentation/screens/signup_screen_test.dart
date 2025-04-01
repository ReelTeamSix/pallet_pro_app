import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../../test_helpers.dart';
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';
import 'package:pallet_pro_app/src/global/widgets/styled_text_field.dart';

// --- Mocks ---
// Use MockAuthController from test_helpers.dart

// Define a simple test-only implementation of AuthController
class TestAuthController extends AuthController {
  final AsyncValue<supabase.User?> _initialState;
  List<({String email, String password})> signUpCalls = [];
  Exception? errorToThrow;
  
  TestAuthController({
    required AsyncValue<supabase.User?> initialState,
    this.errorToThrow,
  }) : _initialState = initialState;
  
  @override
  Future<supabase.User?> build() async {
    return _initialState.valueOrNull;
  }
  
  @override
  AsyncValue<supabase.User?> get state => _initialState;
  
  @override
  Future<void> signUpWithEmail({required String email, required String password}) async {
    signUpCalls.add((email: email, password: password));
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
  }
  
  @override
  Future<void> signInWithEmail({required String email, required String password}) async {}
  
  @override
  Future<void> signOut() async {}
  
  @override
  Future<void> resetPassword({required String email}) async {}
  
  @override
  Future<void> updatePassword(String newPassword) async {}
  
  @override
  supabase.Session? get currentSession => null;
  
  @override
  Future<supabase.Session?> refreshSession() async => null;
}

void main() {
  setupTestEnvironment();

  // Helper function to pump the widget with necessary providers
  Future<TestAuthController> pumpSignUpScreen(WidgetTester tester, {Exception? error}) async {
    // Create a test controller with our exception behavior
    final testController = TestAuthController(
      initialState: const AsyncData<supabase.User?>(null),
      errorToThrow: error,
    );
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Use overrideWithProvider with matching provider type
          authControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<AuthController, supabase.User?>(
              () => testController,
            )
          ),
        ],
        child: const MaterialApp(
          home: SignupScreen(),
        ),
      ),
    );
    
    return testController;
  }

  group('SignUpScreen Widget Tests', () {
    testWidgets('Renders email, password, confirm password fields and sign up button', (WidgetTester tester) async {
      // Arrange
      await pumpSignUpScreen(tester);

      // Act & Assert
      // Use correct ValueKeys from SignupScreen if they exist, otherwise find by type/text
      expect(find.byType(StyledTextField), findsNWidgets(3)); // Find all 3 fields
      expect(find.widgetWithText(StyledTextField, 'Email'), findsOneWidget); // Find by label
      expect(find.widgetWithText(StyledTextField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(StyledTextField, 'Confirm Password'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget); // Find by type
      expect(find.textContaining('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('Shows error messages for empty fields', (WidgetTester tester) async {
      // Arrange
      await pumpSignUpScreen(tester);

      // Act: Tap sign up button
      await tester.tap(find.byType(PrimaryButton)); // Find by type
      await tester.pumpAndSettle();

      // Assert: Check for validation errors (match text from SignupScreen)
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('Shows error message for invalid email format', (WidgetTester tester) async {
      // Arrange
      await pumpSignUpScreen(tester);

      // Act: Enter invalid email and tap sign up
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), 'Password123');
      await tester.enterText(find.widgetWithText(StyledTextField, 'Confirm Password'), 'Password123');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert (match text from SignupScreen)
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows error message for password mismatch', (WidgetTester tester) async {
      // Arrange
      await pumpSignUpScreen(tester);

      // Act: Enter mismatching passwords
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), 'Password123');
      await tester.enterText(find.widgetWithText(StyledTextField, 'Confirm Password'), 'Password456');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Assert (match text from SignupScreen)
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Calls signUpWithEmail on valid submission', (WidgetTester tester) async {
      // Arrange
      final testController = await pumpSignUpScreen(tester);
      
      const testEmail = 'newuser@example.com';
      const testPassword = 'Password123'; // Valid password

      // Act: Enter valid credentials and tap sign up
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), testEmail);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), testPassword);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Confirm Password'), testPassword);
      await tester.tap(find.byType(PrimaryButton));
      
      // Pump multiple times to allow the async operation to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Assert: Verify signUpWithEmail was called with correct parameters
      expect(testController.signUpCalls.length, 1, reason: 'signUpWithEmail should be called once');
      expect(testController.signUpCalls.first.email, testEmail);
      expect(testController.signUpCalls.first.password, testPassword);
    });

    testWidgets('Displays error message when signUp fails', (WidgetTester tester) async {
      // Arrange
      const testEmail = 'existing@example.com';
      const testPassword = 'Password123';
      
      // Create an auth exception with a known error message
      final authException = AuthException('User already registered');
      
      final testController = await pumpSignUpScreen(tester, error: authException);

      // Act: Enter credentials and tap sign up
      await tester.enterText(find.widgetWithText(StyledTextField, 'Email'), testEmail);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Password'), testPassword);
      await tester.enterText(find.widgetWithText(StyledTextField, 'Confirm Password'), testPassword);
      await tester.tap(find.byType(PrimaryButton));
      
      // Allow the async operation to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Assert: Look for the error message in the SnackBar
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('An account with this email already exists. Please use a different email or try signing in.'),
        ),
        findsOneWidget
      );
    });
  });
} 