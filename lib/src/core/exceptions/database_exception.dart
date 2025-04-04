import 'package:pallet_pro_app/src/core/exceptions/app_exception.dart';

/// Exception thrown when database operations fail.
class DatabaseException extends AppException {
  /// Creates a new [DatabaseException].
  DatabaseException({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );

  /// Creates a new [DatabaseException] for not found errors.
  factory DatabaseException.notFound(String message) {
    return DatabaseException(
      message: message,
      code: 'not_found',
    );
  }

  /// Creates a new [DatabaseException] for duplicate record errors.
  factory DatabaseException.duplicate(String message) {
    return DatabaseException(
      message: message,
      code: 'duplicate',
    );
  }

  /// Creates a new [DatabaseException] for invalid input errors.
  factory DatabaseException.invalidInput(String message) {
    return DatabaseException(
      message: message,
      code: 'invalid_input',
    );
  }

  /// Creates a new [DatabaseException] for unknown errors.
  factory DatabaseException.unknown(String message) {
    return DatabaseException(
      message: message,
      code: 'unknown',
    );
  }
} 