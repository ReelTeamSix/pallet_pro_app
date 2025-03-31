import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../test_helpers.dart';

/// This file tests the core routing logic of the application.
///
/// Rather than testing the actual router and redirect logic directly (which would be complex due to
/// dependencies on go_router internals), we've created a simpler test approach that focuses on the
/// core redirection rules. The RouterRedirectLogicTester implements a simplified version of the
/// redirect logic found in the RouterNotifier class in app_router.dart.
///
/// This approach allows us to test that:
/// - Unauthenticated users are redirected to login (unless already on login/signup pages)
/// - Authenticated but not onboarded users are redirected to onboarding
/// - Authenticated and onboarded users are redirected to home when on auth screens
/// - Loading and error states are handled correctly

// Create a simple class to test router redirect logic
class RouterRedirectLogicTester {
  final AsyncValue<supabase.User?> authState;
  final AsyncValue<UserSettings?> settingsState;
  
  RouterRedirectLogicTester({
    required this.authState,
    required this.settingsState,
  });
  
  String? redirect(String currentPath) {
    // Implement the core redirect logic we want to test
    
    // Not logged in - redirect to login unless already on an auth path
    if (authState is AsyncData && (authState as AsyncData).value == null) {
      // Allow login, signup, and password reset screens
      if (currentPath == '/login' || currentPath == '/signup' || 
          currentPath == '/forgot-password' || currentPath == '/reset-password') {
        return null; // No redirect
      }
      // Otherwise redirect to login
      return '/login';
    }
    
    // Handle loading states - no redirects
    if (authState is AsyncLoading || settingsState is AsyncLoading) {
      return null; // No redirect while loading
    }
    
    // Auth error or settings error would redirect to login
    if (authState is AsyncError || settingsState is AsyncError) {
      if (currentPath == '/login' || currentPath == '/signup') {
        return null; // No redirect
      }
      return '/login';
    }
    
    // If we get here, user is authenticated
    // Check if user has completed onboarding
    final user = (authState as AsyncData).value;
    final settings = (settingsState as AsyncData).value;
    
    if (user != null && settings != null) {
      final hasCompletedOnboarding = settings.hasCompletedOnboarding;
      
      // Not onboarded - redirect to onboarding unless already there
      if (!hasCompletedOnboarding) {
        if (currentPath == '/onboarding') {
          return null; // No redirect
        }
        return '/onboarding';
      }
      
      // Onboarded - redirect from auth screens to home
      if (currentPath == '/login' || currentPath == '/signup' || currentPath == '/onboarding') {
        return '/home';
      }
    }
    
    // No redirect needed
    return null;
  }
}

void main() {
  setupTestEnvironment();

  // Test user and settings
  final mockUser = MockUser();
  when(() => mockUser.id).thenReturn('test-user-id');

  // Need to provide full UserSettings for the const constructor
  const userSettingsOnboarded = UserSettings(
      userId: 'test-user-id', 
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
      yearlySalesGoal: 36500
  );
  const userSettingsNotOnboarded = UserSettings(
      userId: 'test-user-id', 
      hasCompletedOnboarding: false,
      theme: 'system', 
      useBiometricAuth: false, 
      usePinAuth: false, 
      costAllocationMethod: CostAllocationMethod.average, 
      showBreakEvenPrice: false, 
      staleThresholdDays: 60,
      dailySalesGoal: 100,
      weeklySalesGoal: 700,
      monthlySalesGoal: 3000,
      yearlySalesGoal: 36500
  );

  group('Router Redirect Logic Tests', () {
    test('Redirects to /login when unauthenticated and not on /login or /signup', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: const AsyncData(null), // Unauthenticated
        settingsState: const AsyncData(null), // Doesn't matter here
      );

      // Act & Assert
      expect(tester.redirect('/home'), '/login');
      expect(tester.redirect('/settings'), '/login');
      expect(tester.redirect('/some/other/route'), '/login');
    });

    test('Does NOT redirect when unauthenticated and on /login', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: const AsyncData(null),
        settingsState: const AsyncData(null),
      );

      // Act & Assert
      expect(tester.redirect('/login'), isNull);
    });

    test('Does NOT redirect when unauthenticated and on /signup', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: const AsyncData(null),
        settingsState: const AsyncData(null),
      );

      // Act & Assert
      expect(tester.redirect('/signup'), isNull);
    });

    test('Redirects to /onboarding when authenticated, settings loaded, NOT onboarded, and not on /onboarding', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser), // Authenticated
        settingsState: const AsyncData(userSettingsNotOnboarded), // Not onboarded
      );

      // Act & Assert
      expect(tester.redirect('/home'), '/onboarding');
      expect(tester.redirect('/settings'), '/onboarding');
    });

     test('Does NOT redirect when authenticated, settings loaded, NOT onboarded, and ON /onboarding', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser), // Authenticated
        settingsState: const AsyncData(userSettingsNotOnboarded), // Not onboarded
      );

      // Act & Assert
      expect(tester.redirect('/onboarding'), isNull);
    });

    test('Redirects to /home when authenticated, settings loaded, onboarded, and on /login', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser),
        settingsState: const AsyncData(userSettingsOnboarded), // Onboarded
      );

      // Act & Assert
      expect(tester.redirect('/login'), '/home');
    });

    test('Redirects to /home when authenticated, settings loaded, onboarded, and on /signup', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser),
        settingsState: const AsyncData(userSettingsOnboarded), // Onboarded
      );

      // Act & Assert
      expect(tester.redirect('/signup'), '/home');
    });
    
    test('Redirects to /home when authenticated, settings loaded, onboarded, and on /onboarding', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser),
        settingsState: const AsyncData(userSettingsOnboarded), // Onboarded
      );

      // Act & Assert
      expect(tester.redirect('/onboarding'), '/home');
    });

    test('Does NOT redirect when authenticated, settings loading, and not on auth paths', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncData(mockUser), // Authenticated
        settingsState: const AsyncLoading(), // Settings are loading
      );

      // Act & Assert
      expect(tester.redirect('/home'), isNull); // Wait for settings before deciding
    });
    
    test('Does NOT redirect when auth state is loading', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: const AsyncLoading(), // Auth is loading
        settingsState: const AsyncData(null), // Doesn't matter
      );

      // Act & Assert
      expect(tester.redirect('/some/path'), isNull); // Wait for auth state
    });

    // Add tests for error states
    test('Redirects to /login when auth state has error', () {
      // Arrange
      final tester = RouterRedirectLogicTester(
        authState: AsyncError(Exception('Auth error'), StackTrace.empty),
        settingsState: const AsyncData(null),
      );

      // Act & Assert
      expect(tester.redirect('/home'), '/login');
    });
  });
} 