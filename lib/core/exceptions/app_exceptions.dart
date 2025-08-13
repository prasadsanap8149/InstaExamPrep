/// Custom exception classes for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Firebase/Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Quiz/Room related exceptions
class QuizException extends AppException {
  const QuizException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// File operation related exceptions
class FileException extends AppException {
  const FileException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}
