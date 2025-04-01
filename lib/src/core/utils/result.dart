import 'package:pallet_pro_app/src/core/exceptions/app_exceptions.dart';

/// Generic Result class that can contain either a success value or an error.
class Result<T> {
  final T? _value;
  final AppException? _error;

  /// Private constructor for success case.
  const Result.success(T value)
      : _value = value,
        _error = null;

  /// Private constructor for error case.
  const Result.failure(AppException error)
      : _value = null,
        _error = error;

  /// Returns true if this Result is a success.
  bool get isSuccess => _error == null;

  /// Returns true if this Result is a failure.
  bool get isFailure => _error != null;

  /// Gets the success value or throws an exception if this is a failure.
  T get value {
    if (isFailure) {
      throw _error!;
    }
    return _value as T;
  }

  /// Gets the error or throws if this is a success.
  AppException get error {
    if (isSuccess) {
      throw Exception('Cannot get error from success Result');
    }
    return _error!;
  }

  /// Maps this Result to a new Result with a different success type.
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      try {
        return Result<R>.success(mapper(value));
      } catch (e) {
        return Result<R>.failure(UnexpectedException('Error during mapping: $e', e));
      }
    } else {
      return Result<R>.failure(error);
    }
  }

  /// Executes one of the provided functions depending on whether this Result is a success or failure.
  R fold<R>(R Function(T) onSuccess, R Function(AppException) onFailure) {
    if (isSuccess) {
      return onSuccess(value);
    } else {
      return onFailure(error);
    }
  }

  /// Transforms this Result using the provided functions.
  ///
  /// If this is a success, applies [onSuccess] to the value.
  /// If this is a failure, applies [onFailure] to the error.
  Result<R> flatMap<R>(
      Result<R> Function(T) onSuccess, Result<R> Function(AppException) onFailure) {
    if (isSuccess) {
      return onSuccess(value);
    } else {
      return onFailure(error);
    }
  }

  /// Creates a new success Result.
  static Result<T> createSuccess<T>(T value) => Result<T>.success(value);

  /// Creates a new failure Result.
  static Result<T> createFailure<T>(AppException error) => Result<T>.failure(error);

  /// Wraps a function that can throw into a Result.
  static Future<Result<T>> guard<T>(Future<T> Function() function) async {
    try {
      return Result<T>.success(await function());
    } catch (e) {
      AppException error;
      if (e is AppException) {
        error = e;
      } else {
        error = UnexpectedException('Unexpected error: $e', e);
      }
      return Result<T>.failure(error);
    }
  }
} 