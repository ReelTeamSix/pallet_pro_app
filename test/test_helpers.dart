import 'package:flutter/material.dart'; // Added for BuildContext if needed later
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
// Added imports for Controller mocks
import 'package:pallet_pro_app/src/features/auth/presentation/providers/auth_controller.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart';
// Added import for GoRouter
import 'package:go_router/go_router.dart';
// Added import for local_auth
import 'package:local_auth/local_auth.dart';


// --- Mocks ---
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockRealtimeClient extends Mock implements RealtimeClient {} // Needed for SupabaseClient mock
class MockFunctionsClient extends Mock implements FunctionsClient {} // Needed for SupabaseClient mock
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {} // Needed for SupabaseClient mock
class MockPostgrestClient extends Mock implements PostgrestClient {} // Needed for SupabaseClient mock
class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {} // Moved up
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {} // Moved up
class MockSupabaseQuerySchema extends Mock implements SupabaseQuerySchema {}
class MockUser extends Mock implements supabase.User {}
// Added Mocks previously in widget_test.dart
class MockSession extends Mock implements Session {}
class MockAuthState extends Mock implements AuthState {}
class MockUserSettings extends Mock implements UserSettings {}
class MockAuthResponse extends Mock implements AuthResponse {} // Add missing AuthResponse mock


// Mock for AuthController - Moved from widget_test.dart
// Note: This provides default stubbing. Override in specific tests if needed.
class MockAuthController extends AsyncNotifier<supabase.User?> implements AuthController {
  @override
  Future<supabase.User?> build() async {
    // Simulate a brief loading period before resolving to null
    // This helps tests that expect an initial loading state
    state = const AsyncLoading(); // Set loading state immediately
    await Future.delayed(const Duration(milliseconds: 1)); // Short delay
    return null; // Default to unauthenticated after delay
  }

  // Add stubs for all methods, returning default values or throwing
  @override Future<void> signInWithEmail({required String email, required String password}) async {}
  @override Future<void> signOut() async { state = const AsyncData(null); } // Simulate state change
  @override Future<void> signUpWithEmail({required String email, required String password}) async {}
  @override Future<void> resetPassword({required String email}) async {}
  @override Future<void> updatePassword(String newPassword) async {}
  @override supabase.Session? get currentSession => null;
  @override Future<supabase.Session?> refreshSession() async => null;
}

// Mock for UserSettingsController - Moved from widget_test.dart
// Note: This provides a default onboarded state. Override if needed.
class MockUserSettingsController extends AsyncNotifier<UserSettings?> implements UserSettingsController {
  @override
  Future<UserSettings?> build() async {
    print("Default MockUserSettingsController: Building...");
    // Simulate loading
    state = const AsyncLoading(); 
    await Future.delayed(const Duration(milliseconds: 1)); 
    // Default to an onboarded user. Override in tests for other scenarios.
    print("Default MockUserSettingsController: Resolving with onboarded state");
    return const UserSettings(
      userId: 'mock-user-id', // Use a generic ID or override in tests
      hasCompletedOnboarding: true,
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

  // Add empty implementations for all methods required by the interface
  @override Future<void> refreshSettings() async {}
  @override Future<void> updateCostAllocationMethod(CostAllocationMethod method) async {}
  @override Future<void> updateHasCompletedOnboarding(bool hasCompleted) async {}
  @override Future<void> updatePinSettings({required bool usePinAuth, String? pinHash}) async {}
  @override Future<void> updateSalesGoals({double? dailyGoal, double? weeklyGoal, double? monthlyGoal, double? yearlyGoal}) async {}
  @override Future<void> updateSettingsFromOnboarding(Map<String, dynamic> updates) async {}
  @override Future<void> updateShowBreakEvenPrice(bool showBreakEvenPrice) async {}
  @override Future<void> updateStaleThresholdDays(int days) async {}
  @override Future<void> updateTheme(String theme) async {}
  @override Future<void> updateUseBiometricAuth(bool useBiometricAuth) async {}
  @override Future<void> updateUserSettings(UserSettings settings) async {}
}

// Added MockBuildContext
class MockBuildContext extends Mock implements BuildContext {}
// Added MockGoRouterState
class MockGoRouterState extends Mock implements GoRouterState {
  // Add stub for uri getter if not already present
  @override
  Uri get uri => Uri.parse('/'); // Provide a default value
}

// Global variable to hold the mock client, initialized early
MockSupabaseClient? _mockSupabaseClient;

// Added AuthenticationOptionsFake for mocktail fallback
class AuthenticationOptionsFake extends Fake implements AuthenticationOptions {}

// --- Helper Functions ---

/// Initializes a mock Supabase instance for testing.
/// Should be called in `setUpAll` in test files or a main test setup file.
Future<MockSupabaseClient> initializeMockSupabase() async {
  // Return existing mock if already initialized in this runner instance
  if (_mockSupabaseClient != null) return _mockSupabaseClient!;

  // Mock SharedPreferences for Supabase to use
  SharedPreferences.setMockInitialValues({});

  // Create mocks
  final mockSupabaseClient = MockSupabaseClient();
  final mockGoTrueClient = MockGoTrueClient();
  final mockRealtimeClient = MockRealtimeClient();
  final mockFunctionsClient = MockFunctionsClient(); // Keep this
  final mockStorageClient = MockSupabaseStorageClient();
  final mockPostgrestClient = MockPostgrestClient();

  // Stub essential getters on MockSupabaseClient
  when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  when(() => mockSupabaseClient.realtime).thenReturn(mockRealtimeClient);
  when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient); // Stubbed functions client
  when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
  when(() => mockSupabaseClient.rest).thenReturn(mockPostgrestClient);

  // Stub default behavior for functions invoke (to fix type error)
  // Return a successful response by default, override in specific tests if needed
  when(() => mockFunctionsClient.invoke(any(), body: any(named: 'body')))
      .thenAnswer((_) async => FunctionResponse(status: 200, data: {'exists': false}));


  when(() => mockSupabaseClient.rpc(any(), params: any(named: 'params')))
        .thenAnswer((_) => MockPostgrestFilterBuilder());
  when(() => mockSupabaseClient.from(any())).thenAnswer((_) => MockSupabaseQueryBuilder());

  // Stub essential methods on MockGoTrueClient
  when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(
        AuthState(AuthChangeEvent.initialSession, null),
      )); // Default to initial signed out state
  when(() => mockGoTrueClient.currentUser).thenReturn(null); // Default to no user
  when(() => mockGoTrueClient.currentSession).thenReturn(null); // Default to no session

  // Store globally for reuse
  _mockSupabaseClient = mockSupabaseClient;

  print("Mock Supabase Initialized (with Functions stub)."); // Debug print

  return mockSupabaseClient;
}


// // Mocks for Supabase Query/Filter builders moved up

/// Helper to register fallback values for commonly mocked types.
void registerFallbackValues() {
  registerFallbackValue(SignOutScope.local);
  registerFallbackValue(UserAttributes());

  // Register fallback values for AsyncValue types
  registerFallbackValue(const AsyncLoading<supabase.User?>());
  registerFallbackValue(const AsyncData<supabase.User?>(null));
  registerFallbackValue(AsyncError<supabase.User?>(Exception('fallback error'), StackTrace.empty));
  // Added fallback for UserSettings? state
  registerFallbackValue(const AsyncLoading<UserSettings?>());
  registerFallbackValue(const AsyncData<UserSettings?>(null));
  registerFallbackValue(AsyncError<UserSettings?>(Exception('fallback error'), StackTrace.empty));

  // Register boolean fallback for isSigningOutProvider
  registerFallbackValue(false);

  // Register fallback for AuthChangeEvent
  registerFallbackValue(AuthChangeEvent.initialSession);

  // Added fallback for UserSettings and CostAllocationMethod
  registerFallbackValue(const UserSettings(userId: '', hasCompletedOnboarding: false));
  registerFallbackValue(CostAllocationMethod.average);
  
  // Added fallback for BuildContext and GoRouterState
  registerFallbackValue(MockBuildContext());
  registerFallbackValue(MockGoRouterState());
  
  // Add fallback for AuthenticationOptions
  registerFallbackValue(AuthenticationOptionsFake());
  
  // Add fallback values for AuthResponse and Session that might be needed in auth tests
  // Only register if MockAuthResponse and MockSession are defined
  // These are defined at the top of the file so they should be available
  registerFallbackValue(MockAuthResponse());
  registerFallbackValue(MockSession());
  
  // Add string fallback for various string parameters
  registerFallbackValue('fallback-string');
  
  // Add map fallback for various map parameters
  registerFallbackValue(<String, dynamic>{});
}


/// Call this in `main()` for your test files to ensure setup.
void setupTestEnvironment() {
  // Ensure Flutter bindings are initialized for widget tests
  TestWidgetsFlutterBinding.ensureInitialized();
  // Register fallback values for mocktail
  registerFallbackValues();
} 