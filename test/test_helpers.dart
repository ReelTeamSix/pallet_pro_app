import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// --- Mocks ---
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockRealtimeClient extends Mock implements RealtimeClient {} // Needed for SupabaseClient mock
class MockFunctionsClient extends Mock implements FunctionsClient {} // Needed for SupabaseClient mock
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {} // Needed for SupabaseClient mock
class MockPostgrestClient extends Mock implements PostgrestClient {} // Needed for SupabaseClient mock
class MockSupabaseQuerySchema extends Mock implements SupabaseQuerySchema {}
class MockUser extends Mock implements supabase.User {}

// Global variable to hold the mock client, initialized early
MockSupabaseClient? _mockSupabaseClient;

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
  final mockFunctionsClient = MockFunctionsClient();
  final mockStorageClient = MockSupabaseStorageClient();
  final mockPostgrestClient = MockPostgrestClient();

  // Stub essential getters on MockSupabaseClient
  when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
  // Stub other clients needed by SupabaseClient implementation (even if just returning the mock)
  when(() => mockSupabaseClient.realtime).thenReturn(mockRealtimeClient);
  when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
  when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
  when(() => mockSupabaseClient.rest).thenReturn(mockPostgrestClient);
  
  // For the schema property, we need to return a function that returns a SupabaseQuerySchema
  // Let's just ignore this property for now since it's not critical for our tests
  // If needed later, we can properly mock it
  
  when(() => mockSupabaseClient.rpc(any(), params: any(named: 'params')))
        .thenAnswer((_) => MockPostgrestFilterBuilder()); // Need MockPostgrestFilterBuilder if rpc is used
  when(() => mockSupabaseClient.from(any())).thenAnswer((_) => MockSupabaseQueryBuilder()); // Need MockSupabaseQueryBuilder if from is used

  // Stub essential methods on MockGoTrueClient
  when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(
        AuthState(AuthChangeEvent.initialSession, null),
      )); // Default to initial signed out state
  when(() => mockGoTrueClient.currentUser).thenReturn(null); // Default to no user
  when(() => mockGoTrueClient.currentSession).thenReturn(null); // Default to no session

  // We'll skip the actual Supabase.initialize call to avoid SharedPreferences issues
  // Instead, we'll just set up our mocks and return them
  
  // Store globally for reuse
  _mockSupabaseClient = mockSupabaseClient;
  
  print("Mock Supabase Initialized."); // Debug print

  return mockSupabaseClient;
}


// Add mocks for Supabase Query/Filter builders if needed by client stubs
class MockPostgrestFilterBuilder<T> extends Mock implements PostgrestFilterBuilder<T> {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}


/// Helper to register fallback values for commonly mocked types.
void registerFallbackValues() {
  registerFallbackValue(SignOutScope.local);
  registerFallbackValue(UserAttributes());
  
  // Register fallback values for AsyncValue types
  registerFallbackValue(const AsyncLoading<supabase.User?>());
  registerFallbackValue(const AsyncData<supabase.User?>(null));
  registerFallbackValue(AsyncError<supabase.User?>(Exception('fallback error'), StackTrace.empty));
  
  // Register boolean fallback for isSigningOutProvider
  registerFallbackValue(false);
  
  // Register fallback for AuthChangeEvent
  registerFallbackValue(AuthChangeEvent.initialSession);
}


/// Call this in `main()` for your test files to ensure setup.
void setupTestEnvironment() {
  // Ensure Flutter bindings are initialized for widget tests
  TestWidgetsFlutterBinding.ensureInitialized();
  // Register fallback values for mocktail
  registerFallbackValues();
} 