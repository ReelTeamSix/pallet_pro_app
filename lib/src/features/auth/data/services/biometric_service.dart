import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

/// Service for biometric authentication.
class BiometricService {
  /// Creates a new [BiometricService] instance.
  BiometricService({
    LocalAuthentication? localAuth,
  }) : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;
  
  // Cache for biometric availability
  bool? _isBiometricAvailableCache;

  /// Checks if biometric authentication is available (synchronous version).
  /// This uses a cached value if available, otherwise returns false.
  bool isBiometricAvailableSync() {
    debugPrint('BiometricService: isBiometricAvailableSync called, cache value: $_isBiometricAvailableCache');
    return _isBiometricAvailableCache ?? false;
  }

  /// Checks if biometric authentication is available.
  Future<bool> isBiometricAvailable() async {
    // Skip on web platform
    if (kIsWeb) {
      debugPrint('BiometricService: Web platform detected, biometrics not available');
      _isBiometricAvailableCache = false;
      return false;
    }

    try {
      // First check for the fragment activity issue
      try {
        // Check if device supports biometrics (this might throw PlatformException with no_fragment_activity)
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        
        if (!isDeviceSupported) {
          debugPrint('BiometricService: Device not supported');
          _isBiometricAvailableCache = false;
          return false;
        }
      } catch (e) {
        // Handle the no_fragment_activity error explicitly
        if (e is PlatformException && 
            (e.code == 'no_fragment_activity' || e.message?.contains('FragmentActivity') == true)) {
          debugPrint('BiometricService: FragmentActivity error detected: ${e.message}');
          _isBiometricAvailableCache = false;
          return false;
        }
        // Rethrow other errors to be handled in the outer catch
        rethrow;
      }
      
      // If we get here, basic device support is available, check biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      debugPrint('BiometricService: canCheckBiometrics=$canCheckBiometrics');
      
      if (!canCheckBiometrics) {
        _isBiometricAvailableCache = false;
        return false;
      }
      
      // Check available biometrics
      List<BiometricType> availableBiometrics = [];
      try {
        availableBiometrics = await _localAuth.getAvailableBiometrics();
        debugPrint('BiometricService: availableBiometrics=$availableBiometrics');
      } catch (e) {
        debugPrint('BiometricService: Error getting available biometrics: $e');
        // Continue with empty list if this fails
      }
      
      bool isAvailable = false;
      if (Platform.isIOS) {
        isAvailable = availableBiometrics.contains(BiometricType.face) || 
                     availableBiometrics.contains(BiometricType.fingerprint);
        debugPrint('BiometricService: iOS platform, isAvailable=$isAvailable');
      } else if (Platform.isAndroid) {
        isAvailable = availableBiometrics.contains(BiometricType.fingerprint) ||
                     availableBiometrics.contains(BiometricType.strong) ||
                     availableBiometrics.contains(BiometricType.weak);
        debugPrint('BiometricService: Android platform, isAvailable=$isAvailable');
      }
      
      // In debug mode, we'll treat biometrics as available even if they're not detected
      if (kDebugMode && !isAvailable && Platform.isAndroid) {
        debugPrint('BiometricService: Debug mode on Android - forcing biometrics to be available');
        isAvailable = true;
      }
      
      _isBiometricAvailableCache = isAvailable;
      return isAvailable;
    } catch (e) {
      debugPrint('BiometricService: Error checking biometric availability: $e');
      _isBiometricAvailableCache = false;
      return false;
    }
  }

  /// Authenticates the user using biometrics.
  Future<bool> authenticate() async {
    debugPrint('BiometricService: authenticate called');
    
    if (kIsWeb) {
      debugPrint('BiometricService: Web platform detected, authentication not available');
      throw FeatureNotAvailableException.platformNotSupported('Biometric authentication');
    }

    try {
      // In debug mode, we'll skip the biometric availability check
      // to allow testing on emulators
      final isAvailable = await isBiometricAvailable();
      debugPrint('BiometricService: isBiometricAvailable=$isAvailable, kDebugMode=$kDebugMode');
      
      if (!kDebugMode && !isAvailable) {
        debugPrint('BiometricService: Biometrics not available and not in debug mode');
        throw PermissionException.biometricPermissionDenied();
      }
      
      // In debug mode on emulators, we'll simulate successful authentication
      if (kDebugMode && !isAvailable) {
        debugPrint('BiometricService: Debug mode, simulating successful authentication');
        return true;
      }
      
      debugPrint('BiometricService: Calling local_auth.authenticate');
      final result = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Pallet Pro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      debugPrint('BiometricService: Authentication result: $result');
      return result;
    } catch (e) {
      debugPrint('BiometricService: Authentication error: $e');
      
      if (e is PermissionException) {
        rethrow;
      }
      
      if (e is PlatformException) {
        if (e.code == auth_error.notAvailable) {
          throw FeatureNotAvailableException.platformNotSupported('Biometric authentication');
        } else if (e.code == auth_error.notEnrolled) {
          throw const PermissionException('No biometrics enrolled on this device');
        } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
          throw const PermissionException('Too many failed attempts. Please try again later.');
        }
      }
      
      throw PermissionException('Failed to authenticate: ${e.toString()}');
    }
  }
}

/// Provider for the [BiometricService].
final biometricService = BiometricService();
