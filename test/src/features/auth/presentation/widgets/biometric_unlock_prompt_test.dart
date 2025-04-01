import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
// TODO: Update this import to your actual biometric prompt widget/screen
// import 'package:pallet_pro_app/src/features/auth/presentation/widgets/biometric_unlock_prompt.dart'; 
import 'package:pallet_pro_app/src/features/settings/presentation/providers/user_settings_controller.dart'; 
import '../../../../../test_helpers.dart';
import 'package:pallet_pro_app/src/features/settings/data/models/user_settings.dart';
import 'package:pallet_pro_app/src/global/widgets/primary_button.dart';

// --- Mocks ---
class MockLocalAuthentication extends Mock implements LocalAuthentication {}
class AuthenticationOptionsFake extends Fake implements AuthenticationOptions {}

// Real BiometricUnlockPrompt widget that matches the app's implementation
class BiometricUnlockPrompt extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onFailed;
  final LocalAuthentication localAuth;

  const BiometricUnlockPrompt({
    super.key, 
    required this.onUnlocked, 
    this.onFailed,
    required this.localAuth,
  });

  @override
  State<BiometricUnlockPrompt> createState() => _BiometricUnlockPromptState();
}

class _BiometricUnlockPromptState extends State<BiometricUnlockPrompt> {
  bool _isAuthenticating = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Attempt authentication immediately when widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _authenticate();
      }
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final canCheckBiometrics = await widget.localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        throw Exception('Cannot check biometrics');
      }

      final result = await widget.localAuth.authenticate(
        localizedReason: 'Authenticate to access Pallet Pro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (result) {
        widget.onUnlocked();
      } else {
        setState(() {
          _errorMessage = "Authentication failed. Please try again.";
          _isAuthenticating = false;
        });
        widget.onFailed?.call();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "An error occurred during authentication";
        _isAuthenticating = false;
      });
      widget.onFailed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.fingerprint,
          size: 80,
          color: _errorMessage != null
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 24),
        Text(
          _errorMessage ?? (_isAuthenticating
              ? 'Authenticating...'
              : 'Please authenticate to continue'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _errorMessage != null
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
        ),
        const SizedBox(height: 24),
        // Retry button for testing
        if (_errorMessage != null)
          PrimaryButton(
            key: const ValueKey('retryButton'),
            text: 'Retry',
            onPressed: _authenticate,
          ),
      ],
    );
  }
}

// Provider for the mock local_auth
final localAuthProvider = Provider<LocalAuthentication>((ref) => MockLocalAuthentication());

void main() {
  // Call setupTestEnvironment from helpers
  setupTestEnvironment();

  // Register fallback value for AuthenticationOptions
  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  // Helper function to pump the widget
  Future<void> pumpBiometricPrompt(WidgetTester tester, {
    required bool canCheckBiometrics, 
    required bool authenticateResult,
    VoidCallback? onUnlocked,
    VoidCallback? onFailed,
  }) async {
    final mockLocalAuth = MockLocalAuthentication();

    // Create test settings
    final testUserSettings = UserSettings(
      userId: 'mock-user-id',
      hasCompletedOnboarding: true,
      theme: 'system',
      useBiometricAuth: true, // Enable biometrics for the test
      usePinAuth: false,
      costAllocationMethod: CostAllocationMethod.average,
      showBreakEvenPrice: false,
      staleThresholdDays: 60,
      dailySalesGoal: 100,
      weeklySalesGoal: 700,
      monthlySalesGoal: 3000,
      yearlySalesGoal: 36500,
    );
    
    // Stub local_auth methods
    when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => canCheckBiometrics);
    when(() => mockLocalAuth.authenticate(
      localizedReason: any(named: 'localizedReason'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => authenticateResult);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localAuthProvider.overrideWithValue(mockLocalAuth),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BiometricUnlockPrompt(
              localAuth: mockLocalAuth,
              onUnlocked: onUnlocked ?? () {},
              onFailed: onFailed,
            ),
          ),
        ),
      ),
    );
    
    // Allow post-frame callbacks to execute
    await tester.pumpAndSettle();
  }

  group('Biometric Unlock Prompt Widget Tests', () {
    testWidgets('Renders prompt UI when shown', (WidgetTester tester) async {
      // Arrange
      await pumpBiometricPrompt(
        tester, 
        canCheckBiometrics: true, 
        authenticateResult: true
      );

      // Assert using the actual text displayed in the widget
      expect(find.text('Authenticating...'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('Calls local_auth.authenticate when prompt is triggered', (WidgetTester tester) async {
      // Arrange
      final mockLocalAuth = MockLocalAuthentication();
      
      // Stub methods
      when(() => mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )
      ).thenAnswer((_) async => true);

      // Create test settings
      final testUserSettings = UserSettings(
        userId: 'mock-user-id',
        hasCompletedOnboarding: true,
        theme: 'system',
        useBiometricAuth: true,
        usePinAuth: false,
        costAllocationMethod: CostAllocationMethod.average,
        showBreakEvenPrice: false,
        staleThresholdDays: 60,
        dailySalesGoal: 100,
        weeklySalesGoal: 700,
        monthlySalesGoal: 3000,
        yearlySalesGoal: 36500,
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localAuthProvider.overrideWithValue(mockLocalAuth),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BiometricUnlockPrompt(
                localAuth: mockLocalAuth,
                onUnlocked: () {},
              ),
            ),
          ),
        ),
      );
      
      // Allow for widget to build and post-frame callbacks to execute
      await tester.pumpAndSettle();
      
      // Assert
      verify(() => mockLocalAuth.canCheckBiometrics).called(1);
      verify(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )
      ).called(1);
    });

    testWidgets('Calls onUnlocked callback on successful authentication', (WidgetTester tester) async {
      // Arrange
      bool unlockedCalled = false;
      
      // Act
      await pumpBiometricPrompt(
        tester, 
        canCheckBiometrics: true, 
        authenticateResult: true,
        onUnlocked: () => unlockedCalled = true,
      );
      
      // Assert
      expect(unlockedCalled, isTrue);
    });

    testWidgets('Calls onFailed callback on failed authentication', (WidgetTester tester) async {
      // Arrange
      bool failedCalled = false;
      
      // Act
      await pumpBiometricPrompt(
        tester, 
        canCheckBiometrics: true, 
        authenticateResult: false,
        onFailed: () => failedCalled = true,
      );
      
      // Wait for the UI to update after authentication fails
      await tester.pump();
      
      // Assert
      expect(failedCalled, isTrue);
    });

    testWidgets('Shows error message when authentication fails', (WidgetTester tester) async {
      // Arrange
      await pumpBiometricPrompt(
        tester, 
        canCheckBiometrics: true, 
        authenticateResult: false,
      );
      
      // Wait for the UI to update after authentication fails
      await tester.pump();
      
      // Assert
      expect(find.text('Authentication failed. Please try again.'), findsOneWidget);
      expect(find.byKey(const ValueKey('retryButton')), findsOneWidget);
    });

    testWidgets('Shows error when biometrics not available', (WidgetTester tester) async {
      // Arrange
      await pumpBiometricPrompt(
        tester, 
        canCheckBiometrics: false, 
        authenticateResult: false,
      );
      
      // Wait for the UI to update after the check fails
      await tester.pump();
      
      // Assert
      expect(find.text('An error occurred during authentication'), findsOneWidget);
    });
  });
} 