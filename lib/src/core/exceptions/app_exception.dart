/// Base exception class for application errors.
class AppException implements Exception {
  /// A message describing the error.
  final String message;

  /// An optional error code for error handling.
  final String? code;

  /// Optional additional details about the error.
  final dynamic details;

  /// Creates a new [AppException] with the given message, code, and details.
  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Exception thrown when an entity is not found.
class NotFoundException extends AppException {
  NotFoundException(String message, {String? code, dynamic details})
      : super(
          message: message,
          code: code ?? 'not_found',
          details: details,
        );
}

/// Exception thrown when validations fail.
class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic details})
      : super(
          message: message,
          code: code ?? 'validation_error',
          details: details,
        );
}

/// Exception thrown when an unexpected error occurs.
class UnexpectedException extends AppException {
  UnexpectedException(String message, {String? code, dynamic details})
      : super(
          message: message,
          code: code ?? 'unexpected_error',
          details: details,
        );
}

/// Exception thrown when a user is not authorized to perform an action.
class UnauthorizedException extends AppException {
  UnauthorizedException(String message, {String? code, dynamic details})
      : super(
          message: message,
          code: code ?? 'unauthorized',
          details: details,
        );
}

/// Exception thrown when a network operation fails.
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details})
      : super(
          message: message,
          code: code ?? 'network_error',
          details: details,
        );
} 