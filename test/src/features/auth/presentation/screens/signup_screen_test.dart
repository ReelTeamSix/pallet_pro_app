import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../../test_helpers.dart';

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
  Future<void> pumpSignUpScreen(WidgetTester tester) async {
    // Create a simpler mock implementation without using the problematic state/controller
    final testController = TestAuthController(
      initialState: const AsyncData<supabase.User?>(null),
      errorToThrow: null,
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
    
    return Future.value();
  }

  group('SignUpScreen Widget Tests', () {
    testWidgets('Renders email, password, confirm password fields and sign up button', (WidgetTester tester) async {
      // Arrange
      await pumpSignUpScreen(tester);

      // Act & Assert
      // Use correct ValueKeys from SignupScreen if they exist, otherwise find by type/text
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
      // Use correct text/casing from SignupScreen
      expect(find.text('Create Account'), findsWidgets);
      expect(find.textContaining('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('Shows error messages for empty fields', (WidgetTester tester) async {
      // Arrange
      final testController = TestAuthController(
        initialState: const AsyncData<supabase.User?>(null),
        errorToThrow: null,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Act: Tap sign up button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert: Check for validation errors (match text from SignupScreen)
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(testController.signUpCalls.isEmpty, isTrue); // No calls made
    });

    testWidgets('Shows error message for invalid email format', (WidgetTester tester) async {
      // Arrange
      final testController = TestAuthController(
        initialState: const AsyncData<supabase.User?>(null),
        errorToThrow: null,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Act: Enter invalid email and tap sign up
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert (match text from SignupScreen)
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(testController.signUpCalls.isEmpty, isTrue); // No calls made
    });

    testWidgets('Shows error message for password mismatch', (WidgetTester tester) async {
      // Arrange
      final testController = TestAuthController(
        initialState: const AsyncData<supabase.User?>(null),
        errorToThrow: null,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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

      // Act: Enter mismatching passwords
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // Assert (match text from SignupScreen)
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(testController.signUpCalls.isEmpty, isTrue); // No calls made
    });

    testWidgets('Calls signUpWithEmail on valid submission', (WidgetTester tester) async {
      // Arrange
      final signUpCalls = <({String email, String password})>[];
      final authState = AsyncData<supabase.User?>(null);

      // Create a test controller with our callback
      final testController = TestAuthController(
        initialState: authState,
        errorToThrow: null,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
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
      
      const testEmail = 'newuser@example.com';
      const testPassword = 'password1234'; // Ensure >= 8 chars

      // Act: Enter valid credentials and tap sign up
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), testEmail);
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), testPassword);
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), testPassword);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pump(); // Start the process

      // Assert: Verify signUpWithEmail was called with correct parameters
      expect(testController.signUpCalls.length, 1);
      expect(testController.signUpCalls.first.email, testEmail);
      expect(testController.signUpCalls.first.password, testPassword);
    });

    testWidgets('Displays error message when signUp fails', (WidgetTester tester) async {
       // Arrange
       const testEmail = 'existing@example.com';
       const testPassword = 'password1234';
       // Use specific AuthException for better testing
       final exception = AuthException('User already registered'); 
       
       final testController = TestAuthController(
         initialState: const AsyncData<supabase.User?>(null),
         errorToThrow: exception,
       );
       
       await tester.pumpWidget(
         ProviderScope(
           overrides: [
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
 
       // Act: Enter credentials and tap sign up
       await tester.enterText(find.widgetWithText(TextFormField, 'Email'), testEmail);
       await tester.enterText(find.widgetWithText(TextFormField, 'Password'), testPassword);
       await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), testPassword);
       await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
       await tester.pumpAndSettle();
 
       // Assert: Look specifically for the error message in the Container, not in the SnackBar
       expect(
         find.descendant(
           of: find.byType(Container),
           matching: find.text('An account with this email already exists. Please use a different email or try signing in.'),
         ),
         findsOneWidget
       );
       
       // Verify SnackBar also contains the error (optional, but confirms both UI elements show the error)
       expect(
         find.descendant(
           of: find.byType(SnackBar),
           matching: find.text('An account with this email already exists. Please use a different email or try signing in.'),
         ),
         findsOneWidget
       );
     });

    // Add more tests:
    // - Password visibility toggle for both fields
    // - Navigation to login screen
    // - Handling loading states correctly
  });
} 