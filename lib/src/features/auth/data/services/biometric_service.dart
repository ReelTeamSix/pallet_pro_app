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

  /// Checks if biometric authentication is available.
  Future<bool> isBiometricAvailable() async {
    // Skip on web platform
    if (kIsWeb) {
      return false;
    }

    try {
      // Check if device supports biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }
      
      // Check available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      if (Platform.isIOS) {
        return availableBiometrics.contains(BiometricType.face) || 
               availableBiometrics.contains(BiometricType.fingerprint);
      } else if (Platform.isAndroid) {
        return availableBiometrics.contains(BiometricType.fingerprint) ||
               availableBiometrics.contains(BiometricType.strong) ||
               availableBiometrics.contains(BiometricType.weak);
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Authenticates the user using biometrics.
  Future<bool> authenticate() async {
    if (kIsWeb) {
      throw FeatureNotAvailableException.platformNotSupported('Biometric authentication');
    }

    try {
      // In debug mode, we'll skip the biometric availability check
      // to allow testing on emulators
      if (!kDebugMode && !await isBiometricAvailable()) {
        throw PermissionException.biometricPermissionDenied();
      }
      
      // In debug mode on emulators, we'll simulate successful authentication
      if (kDebugMode && !(await isBiometricAvailable())) {
        debugPrint('Debug mode: Simulating successful biometric authentication');
        return true;
      }
      
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Pallet Pro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
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
