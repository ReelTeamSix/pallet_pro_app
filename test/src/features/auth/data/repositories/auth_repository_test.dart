import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:pallet_pro_app/src/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:gotrue/src/types/auth_exception.dart' as gotrue;
import '../../../../../test_helpers.dart';

// --- Mocks ---
// Using MockSupabaseClient from test_helpers.dart
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUserResponse extends Mock implements UserResponse {}

void main() {
  setupTestEnvironment();

  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late AuthRepository authRepository;
  late MockUser mockUser;
  late MockSession mockSession;
  late MockAuthResponse mockAuthResponse;
  late MockUserResponse mockUserResponse;

  setUpAll(() async {
    mockSupabaseClient = await initializeMockSupabase();
    mockGoTrueClient = mockSupabaseClient.auth as MockGoTrueClient;
  });

  setUp(() {
    mockUser = MockUser();
    mockSession = MockSession();
    mockAuthResponse = MockAuthResponse();
    mockUserResponse = MockUserResponse();

    authRepository = SupabaseAuthRepository(client: mockSupabaseClient);

    when(() => mockAuthResponse.user).thenReturn(mockUser);
    when(() => mockAuthResponse.session).thenReturn(mockSession);
    when(() => mockUserResponse.user).thenReturn(mockUser);

    reset(mockGoTrueClient);

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(
          AuthState(AuthChangeEvent.initialSession, null),
        ));
    when(() => mockGoTrueClient.currentUser).thenReturn(null);
    when(() => mockGoTrueClient.currentSession).thenReturn(null);

    when(() => mockGoTrueClient.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockAuthResponse);
    when(() => mockGoTrueClient.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        )).thenAnswer((_) async => mockAuthResponse);
    when(() => mockGoTrueClient.signOut(scope: any(named: 'scope')))
        .thenAnswer((_) async {});
    when(() => mockGoTrueClient.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        )).thenAnswer((_) async {});
    when(() => mockGoTrueClient.updateUser(
          any(),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        )).thenAnswer((_) async => mockUserResponse);
    when(() => mockGoTrueClient.refreshSession())
        .thenAnswer((_) async => mockAuthResponse);
  });

  group('AuthRepository Tests', () {
    group('signInWithEmail', () {
      test('Calls Supabase signInWithPassword with correct parameters', () async {
        const email = 'test@example.com';
        const password = 'password123';
        when(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password))
            .thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.signInWithEmail(email: email, password: password);

        verify(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password)).called(1);
        expect(result, equals(mockAuthResponse));
      });

      test('Throws AuthException when Supabase throws GoTrueAuthException', () async {
        const email = 'fail@example.com';
        const password = 'wrong';
        final gotrueException = gotrue.AuthException('Invalid login credentials');
        when(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password))
            .thenThrow(gotrueException);

        expect(
          () => authRepository.signInWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Sign in failed: Invalid login credentials'),
          )),
        );
        verify(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password)).called(1);
      });

      test('Throws AuthException when Supabase throws generic exception', () async {
        const email = 'fail@example.com';
        const password = 'wrong';
        final genericException = Exception('Network error');
        when(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password))
            .thenThrow(genericException);

        expect(
          () => authRepository.signInWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Sign in failed: Exception: Network error'),
          )),
        );
        verify(() => mockGoTrueClient.signInWithPassword(email: email.trim(), password: password)).called(1);
      });
    });

    group('signUpWithEmail', () {
      test('Calls Supabase signUp with correct parameters', () async {
        const email = 'new@example.com';
        const password = 'newpassword';
        when(() => mockGoTrueClient.signUp(
            email: email.trim(), 
            password: password, 
            emailRedirectTo: 'io.supabase.palletproapp://login-callback/'
        )).thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.signUpWithEmail(email: email, password: password);

        verify(() => mockGoTrueClient.signUp(
            email: email.trim(), 
            password: password, 
            emailRedirectTo: 'io.supabase.palletproapp://login-callback/'
        )).called(1);
        expect(result, equals(mockAuthResponse));
      });

      test('Throws AuthException when user signup returns null response data', () async {
        const email = 'partial@example.com';
        const password = 'password';
        when(() => mockAuthResponse.user).thenReturn(null);
        when(() => mockAuthResponse.session).thenReturn(null);
        
        expect(
          () => authRepository.signUpWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Sign up failed: User already registered'),
          )),
        );
      });

      test('Throws AuthException when Supabase throws GoTrueAuthException about existing user', () async {
        const email = 'exists2@example.com';
        const password = 'password';
        final gotrueException = gotrue.AuthException('User already registered');
        when(() => mockGoTrueClient.signUp(
            email: email.trim(), 
            password: password, 
            emailRedirectTo: 'io.supabase.palletproapp://login-callback/'
        )).thenThrow(gotrueException);

        expect(
          () => authRepository.signUpWithEmail(email: email, password: password),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Sign up failed: User already registered'),
          )),
        );
      });
    });

    group('signOut', () {
      test('Calls Supabase signOut with local scope', () async {
        when(() => mockGoTrueClient.signOut(scope: SignOutScope.local)).thenAnswer((_) async {});

        await authRepository.signOut();

        verify(() => mockGoTrueClient.signOut(scope: SignOutScope.local)).called(1);
      });

      test('Throws AuthException when Supabase throws', () async {
        final gotrueException = gotrue.AuthException('Sign out failed');
        when(() => mockGoTrueClient.signOut(scope: SignOutScope.local)).thenThrow(gotrueException);

        expect(
          () => authRepository.signOut(),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Sign out failed: Sign out failed'),
          )),
        );
        verify(() => mockGoTrueClient.signOut(scope: SignOutScope.local)).called(1);
      });
    });

    group('currentUser', () {
      test('Returns Supabase currentUser when not null', () {
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final result = authRepository.currentUser;

        verify(() => mockGoTrueClient.currentUser).called(1);
        expect(result, equals(mockUser));
      });

      test('Returns null when Supabase currentUser is null', () {
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        final result = authRepository.currentUser;

        verify(() => mockGoTrueClient.currentUser).called(1);
        expect(result, isNull);
      });
    });

    group('currentSession', () {
      test('Returns Supabase currentSession when not null', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        final result = authRepository.currentSession;

        verify(() => mockGoTrueClient.currentSession).called(1);
        expect(result, equals(mockSession));
      });

      test('Returns null when Supabase currentSession is null', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);

        final result = authRepository.currentSession;

        verify(() => mockGoTrueClient.currentSession).called(1);
        expect(result, isNull);
      });
    });

    group('resetPassword', () {
      test('Calls Supabase resetPasswordForEmail with correct parameters', () async {
        const email = 'reset@example.com';
        // This test needs to account for the redirectTo being platform-specific
        when(() => mockGoTrueClient.resetPasswordForEmail(
            email.trim(), 
            redirectTo: 'io.supabase.palletproapp://login-callback/'
        )).thenAnswer((_) async {});

        await authRepository.resetPassword(email: email);

        verify(() => mockGoTrueClient.resetPasswordForEmail(
            email.trim(), 
            redirectTo: 'io.supabase.palletproapp://login-callback/'
        )).called(1);
      });

      test('Throws AuthException when Supabase throws', () async {
        const email = 'fail_reset@example.com';
        final genericException = Exception('Error sending reset email');
        when(() => mockGoTrueClient.resetPasswordForEmail(
            email.trim(), 
            redirectTo: 'io.supabase.palletproapp://login-callback/'
        )).thenThrow(genericException);

        expect(
          () => authRepository.resetPassword(email: email),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Failed to reset password: Exception: Error sending reset email'),
          )),
        );
      });
    });

    group('updatePassword', () {
      test('Calls Supabase updateUser with correct parameters', () async {
        const newPassword = 'newSecurePassword';
        when(() => mockGoTrueClient.updateUser(
            any(), 
            emailRedirectTo: null
        )).thenAnswer((_) async => mockUserResponse);

        await authRepository.updatePassword(newPassword: newPassword);

        final captured = verify(() => mockGoTrueClient.updateUser(
            captureAny(), 
            emailRedirectTo: null
        )).captured;
        expect(captured.single, isA<UserAttributes>());
        expect((captured.single as UserAttributes).password, equals(newPassword));
      });

      test('Throws AuthException when Supabase throws', () async {
        const newPassword = 'weakPassword';
        final gotrueException = gotrue.AuthException('Password is too weak');
        when(() => mockGoTrueClient.updateUser(
            any(), 
            emailRedirectTo: null
        )).thenThrow(gotrueException);

        expect(
          () => authRepository.updatePassword(newPassword: newPassword),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Failed to update password: Password is too weak'),
          )),
        );
      });
    });

    group('refreshSession', () {
      test('Calls Supabase refreshSession and returns the session from AuthResponse', () async {
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(() => mockGoTrueClient.refreshSession()).thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.refreshSession();

        verify(() => mockGoTrueClient.refreshSession()).called(1);
        expect(result, equals(mockSession));
      });

      test('Returns null if refreshSession response has no session', () async {
        when(() => mockAuthResponse.session).thenReturn(null);
        when(() => mockGoTrueClient.refreshSession()).thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.refreshSession();

        verify(() => mockGoTrueClient.refreshSession()).called(1);
        expect(result, isNull);
      });

      test('Throws session expired exception when Supabase throws GoTrueAuthException', () async {
        final gotrueException = gotrue.AuthException('Refresh token expired');
        when(() => mockGoTrueClient.refreshSession()).thenThrow(gotrueException);

        expect(
          () => authRepository.refreshSession(),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            equals('Your session has expired. Please sign in again.'),
          )),
        );
        verify(() => mockGoTrueClient.refreshSession()).called(1);
      });
    });
  });
}
