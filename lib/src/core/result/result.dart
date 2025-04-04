/// A class representing the result of an operation that can either succeed or fail.
class Result<T> {
  final T? _value;
  final dynamic _error;
  final bool _isSuccess;

  const Result._({
    T? value,
    dynamic error,
    required bool isSuccess,
  })  : _value = value,
        _error = error,
        _isSuccess = isSuccess;

  /// Creates a success result with the given value.
  factory Result.success(T value) => Result._(
        value: value,
        isSuccess: true,
      );

  /// Creates a failure result with the given error.
  factory Result.failure(dynamic error) => Result._(
        error: error,
        isSuccess: false,
      );

  /// Returns whether this result is a success.
  bool get isSuccess => _isSuccess;

  /// Returns whether this result is a failure.
  bool get isFailure => !_isSuccess;

  /// Returns the value if this result is a success, otherwise throws an error.
  T get value {
    if (_isSuccess) {
      return _value as T;
    }
    throw StateError('Cannot get value from failure result');
  }

  /// Returns the error if this result is a failure, otherwise returns null.
  dynamic get error => _isSuccess ? null : _error;

  /// Executes one of the given callbacks depending on whether this result is a success or failure.
  R when<R>({
    required R Function(T value) success,
    required R Function(dynamic error) failure,
  }) {
    if (_isSuccess) {
      return success(_value as T);
    } else {
      return failure(_error);
    }
  }

  /// Maps the value of this result if it is a success, otherwise returns a failure result with the same error.
  Result<R> map<R>(R Function(T value) mapper) {
    if (_isSuccess) {
      try {
        return Result.success(mapper(_value as T));
      } catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(_error);
    }
  }

  /// Flat-maps the value of this result if it is a success, otherwise returns a failure result with the same error.
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    if (_isSuccess) {
      try {
        return mapper(_value as T);
      } catch (e) {
        return Result.failure(e);
      }
    } else {
      return Result.failure(_error);
    }
  }

  /// Creates a new result by applying the given mapper to the value of this result if it is a success,
  /// or the given error mapper to the error of this result if it is a failure.
  Result<R> fold<R>({
    required R Function(T value) success,
    required R Function(dynamic error) failure,
  }) {
    try {
      if (_isSuccess) {
        return Result.success(success(_value as T));
      } else {
        return Result.success(failure(_error));
      }
    } catch (e) {
      return Result.failure(e);
    }
  }
}

/// Extension to enable handling values and errors with method chaining.
extension ResultExtension<T> on Result<T> {
  /// Executes the given callback if this result is a success, otherwise does nothing.
  Result<T> onSuccess(void Function(T value) callback) {
    if (isSuccess) {
      callback(value);
    }
    return this;
  }

  /// Executes the given callback if this result is a failure, otherwise does nothing.
  Result<T> onFailure(void Function(dynamic error) callback) {
    if (isFailure) {
      callback(error);
    }
    return this;
  }
} 