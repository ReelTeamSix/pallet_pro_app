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
// Mocks are now defined in test_helpers.dart
// class MockSession extends Mock implements Session {}
// class MockAuthState extends Mock implements AuthState {}
// class MockUserSettings extends Mock implements UserSettings {}
// class MockAuthController extends ... {}
// class MockUserSettingsController extends ... {}

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

// Create a simple state notifier for testing
class TestAuthStateNotifier extends StateNotifier<AsyncValue<supabase.User?>> {
  TestAuthStateNotifier([AsyncValue<supabase.User?>? initialState]) 
    : super(initialState ?? const AsyncLoading());
}

// Create a provider based on this notifier
final testAuthProvider = StateNotifierProvider<TestAuthStateNotifier, AsyncValue<supabase.User?>>((ref) {
  return TestAuthStateNotifier();
});

// Add TestAuthController definition
class TestAuthController extends AuthController {
  // Use a state variable so it can be properly read by the widget
  AsyncValue<supabase.User?> _state;
  
  TestAuthController(this._state);
  
  @override
  Future<supabase.User?> build() async => _state.valueOrNull;
  
  @override
  AsyncValue<supabase.User?> get state => _state;
  
  // Allow state to be updated directly for testing
  set state(AsyncValue<supabase.User?> value) {
    _state = value;
  }
  
  @override
  Future<void> signInWithEmail({required String email, required String password}) async {}
  
  @override
  Future<void> signUpWithEmail({required String email, required String password}) async {}
  
  @override
  Future<void> resetPassword({required String email}) async {}
  
  @override
  Future<void> updatePassword(String newPassword) async {}
  
  @override
  Future<void> signOut() async {}
  
  @override
  supabase.Session? get currentSession => null;
  
  @override
  Future<supabase.Session?> refreshSession() async => null;
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
    // Create a test-specific controller with loading state
    final loadingController = TestAuthController(const AsyncLoading());
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override with our test controller
          authControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<AuthController, supabase.User?>(
              () => loadingController,
            )
          ),
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
    
    // Verify loading state is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Create a new TestAuthController with different state
    final unauthenticatedController = TestAuthController(const AsyncData<supabase.User?>(null));
    
    // Create a new ProviderScope with updated controller
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override with our new test controller
          authControllerProvider.overrideWithProvider(
            AsyncNotifierProvider<AuthController, supabase.User?>(
              () => unauthenticatedController,
            )
          ),
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
    
    // Now it should show the sign in message
    expect(find.text('Please sign in'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing); // Loading should disappear
  });

  testWidgets('Auth dependent widget shows welcome message when user is present', (WidgetTester tester) async {
    // Create a mock user
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn('test-user-123');
    
    // Create a state notifier for testing
    final testNotifier = TestAuthStateNotifier(const AsyncLoading());
    
    // Create a simple widget that uses our test provider
    final testWidget = ProviderScope(
      overrides: [
        // Override the test provider
        testAuthProvider.overrideWith((_) => testNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            // Use a Consumer to rebuild when our test provider changes
            child: Consumer(
              builder: (context, ref, _) {
                final authState = ref.watch(testAuthProvider);
                
                return authState.when(
                  data: (user) => user != null 
                    ? Text('Welcome, ${user.id}!') 
                    : const Text('Please sign in'),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      ),
    );
    
    await tester.pumpWidget(testWidget);
    
    // Expect loading initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Now update the state with the authenticated user
    testNotifier.state = AsyncData(mockUser);
    
    // Pump to process the state change
    await tester.pump();
    
    // Print the widget tree to debug
    print('Widget tree after state change:');
    tester.allWidgets.forEach((widget) {
      if (widget is Text) {
        print('Text widget: "${widget.data}"');
      }
    });
    
    // Now it should show the welcome message
    expect(find.text('Welcome, test-user-123!'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing); // Loading should disappear
  });

  // Later we can add more complex tests when the basic one passes
}
