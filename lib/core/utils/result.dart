/// Result wrapper for handling success and error states
abstract class Result<T> {
  const Result();

  /// Check if the result is successful
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is Failure<T>;

  /// Get the data if successful, null otherwise
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Get the exception if failed, null otherwise
  Exception? get exception => isFailure ? (this as Failure<T>).exception : null;

  /// Transform the data if successful, otherwise return the same failure
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure(e is Exception ? e : Exception(e.toString()));
      }
    }
    return Failure((this as Failure<T>).exception);
  }

  /// Execute a function if successful, otherwise return the same failure
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (isSuccess) {
      try {
        return transform((this as Success<T>).data);
      } catch (e) {
        return Failure(e is Exception ? e : Exception(e.toString()));
      }
    }
    return Failure((this as Failure<T>).exception);
  }

  /// Fold the result into a single value
  R fold<R>(R Function(Exception exception) onFailure, R Function(T data) onSuccess) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).exception);
    }
  }
}

/// Successful result containing data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Failed result containing an exception
class Failure<T> extends Result<T> {
  final Exception exception;

  const Failure(this.exception);

  @override
  String toString() => 'Failure(exception: $exception)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.exception == exception;
  }

  @override
  int get hashCode => exception.hashCode;
}

/// Extension methods for easier result handling
extension ResultExtensions<T> on Result<T> {
  /// Execute a callback if successful
  void onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
  }

  /// Execute a callback if failed
  void onFailure(void Function(Exception exception) callback) {
    if (isFailure) {
      callback((this as Failure<T>).exception);
    }
  }
}

/// Utility functions for creating results
class ResultUtils {
  /// Create a successful result
  static Result<T> success<T>(T data) => Success(data);

  /// Create a failed result
  static Result<T> failure<T>(Exception exception) => Failure(exception);

  /// Execute a function safely and return a result
  static Result<T> execute<T>(T Function() function) {
    try {
      return Success(function());
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Execute an async function safely and return a result
  static Future<Result<T>> executeAsync<T>(Future<T> Function() function) async {
    try {
      final data = await function();
      return Success(data);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
}
