/// Base exception class for all application-specific exceptions.
abstract class AppException implements Exception {
  /// Creates a new [AppException] with the given [message].
  const AppException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails.
class AuthException extends AppException {
  /// Creates a new [AuthException] with the given [message].
  const AuthException(super.message);

  /// Creates a new [AuthException] for sign-in failure.
  factory AuthException.signInFailed(String details) =>
      AuthException('Sign in failed: $details');

  /// Creates a new [AuthException] for sign-up failure.
  factory AuthException.signUpFailed(String details) =>
      AuthException('Sign up failed: $details');

  /// Creates a new [AuthException] for sign-out failure.
  factory AuthException.signOutFailed(String details) =>
      AuthException('Sign out failed: $details');

  /// Creates a new [AuthException] for session expiration.
  factory AuthException.sessionExpired() =>
      const AuthException('Your session has expired. Please sign in again.');
}

/// Exception thrown when a network request fails.
class NetworkException extends AppException {
  /// Creates a new [NetworkException] with the given [message].
  const NetworkException(super.message);

  /// Creates a new [NetworkException] for connection failure.
  factory NetworkException.connectionFailed() =>
      const NetworkException('Unable to connect to the server. Please check your internet connection.');

  /// Creates a new [NetworkException] for timeout.
  factory NetworkException.timeout() =>
      const NetworkException('The request timed out. Please try again.');

  /// Creates a new [NetworkException] for server error.
  factory NetworkException.serverError(String details) =>
      NetworkException('Server error: $details');
}

/// Exception thrown when a database operation fails.
class DatabaseException extends AppException {
  /// Creates a new [DatabaseException] with the given [message].
  const DatabaseException(super.message);

  /// Creates a new [DatabaseException] for creation failure.
  factory DatabaseException.creationFailed(String entity, String details) =>
      DatabaseException('Failed to create $entity: $details');

  /// Creates a new [DatabaseException] for update failure.
  factory DatabaseException.updateFailed(String entity, String details) =>
      DatabaseException('Failed to update $entity: $details');

  /// Creates a new [DatabaseException] for deletion failure.
  factory DatabaseException.deletionFailed(String entity, String details) =>
      DatabaseException('Failed to delete $entity: $details');

  /// Creates a new [DatabaseException] for fetch failure.
  factory DatabaseException.fetchFailed(String entity, String details) =>
      DatabaseException('Failed to fetch $entity: $details');
}

/// Exception thrown when a storage operation fails.
class StorageException extends AppException {
  /// Creates a new [StorageException] with the given [message].
  const StorageException(super.message);

  /// Creates a new [StorageException] for upload failure.
  factory StorageException.uploadFailed(String details) =>
      StorageException('Failed to upload file: $details');

  /// Creates a new [StorageException] for download failure.
  factory StorageException.downloadFailed(String details) =>
      StorageException('Failed to download file: $details');

  /// Creates a new [StorageException] for deletion failure.
  factory StorageException.deletionFailed(String details) =>
      StorageException('Failed to delete file: $details');
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  /// Creates a new [ValidationException] with the given [message].
  const ValidationException(super.message);

  /// Creates a new [ValidationException] for invalid input.
  factory ValidationException.invalidInput(String field, String details) =>
      ValidationException('Invalid $field: $details');

  /// Creates a new [ValidationException] for required field.
  factory ValidationException.requiredField(String field) =>
      ValidationException('$field is required');
}

/// Exception thrown when a permission is denied.
class PermissionException extends AppException {
  /// Creates a new [PermissionException] with the given [message].
  const PermissionException(super.message);

  /// Creates a new [PermissionException] for camera permission.
  factory PermissionException.cameraPermissionDenied() =>
      const PermissionException('Camera permission is required to scan barcodes');

  /// Creates a new [PermissionException] for storage permission.
  factory PermissionException.storagePermissionDenied() =>
      const PermissionException('Storage permission is required to access photos');

  /// Creates a new [PermissionException] for biometric permission.
  factory PermissionException.biometricPermissionDenied() =>
      const PermissionException('Biometric permission is required for secure authentication');
}

/// Exception thrown when a feature is not available.
class FeatureNotAvailableException extends AppException {
  /// Creates a new [FeatureNotAvailableException] with the given [message].
  const FeatureNotAvailableException(super.message);

  /// Creates a new [FeatureNotAvailableException] for platform-specific feature.
  factory FeatureNotAvailableException.platformNotSupported(String feature) =>
      FeatureNotAvailableException('$feature is not available on this platform');
}
