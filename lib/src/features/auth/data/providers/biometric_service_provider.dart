import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pallet_pro_app/src/features/auth/data/services/biometric_service.dart';

/// Provider for the [BiometricService].
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});
