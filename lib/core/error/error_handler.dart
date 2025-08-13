import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../exceptions/app_exceptions.dart';

/// Centralized error handler for the application
class ErrorHandler {
  static const String _tag = 'ErrorHandler';

  /// Handle different types of exceptions and return user-friendly messages
  static AppException handleError(dynamic error) {
    if (kDebugMode) {
      print('$_tag: Handling error: $error');
    }

    if (error is AppException) {
      return error;
    }

    // Firebase Auth exceptions
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }

    // Firebase Core exceptions
    if (error is FirebaseException) {
      return _handleFirebaseException(error);
    }

    // Network exceptions
    if (error is SocketException) {
      return const NetworkException(
        'No internet connection. Please check your network settings.',
        code: 'SOCKET_EXCEPTION',
      );
    }

    if (error is TimeoutException) {
      return const NetworkException(
        'Request timeout. Please try again.',
        code: 'TIMEOUT_EXCEPTION',
      );
    }

    // File system exceptions
    if (error is FileSystemException) {
      return FileException(
        'File operation failed: ${error.message}',
        code: 'FILE_SYSTEM_EXCEPTION',
        details: error,
      );
    }

    // Format exceptions
    if (error is FormatException) {
      return ValidationException(
        'Invalid data format: ${error.message}',
        code: 'FORMAT_EXCEPTION',
        details: error,
      );
    }

    // Generic exceptions
    return AppException(
      'An unexpected error occurred. Please try again.',
      code: 'UNKNOWN_EXCEPTION',
      details: error,
    );
  }

  static AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'weak-password':
        message = 'Password is too weak. Please choose a stronger password.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support.';
        break;
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed. Please contact support.';
        break;
      case 'requires-recent-login':
        message = 'Please log in again to complete this action.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please try again.';
    }

    return AuthException(message, code: e.code, details: e);
  }

  static DatabaseException _handleFirebaseException(FirebaseException e) {
    String message;

    switch (e.code) {
      case 'permission-denied':
        message = 'You don\'t have permission to access this resource.';
        break;
      case 'unavailable':
        message = 'Service is currently unavailable. Please try again later.';
        break;
      case 'deadline-exceeded':
        message = 'Request timeout. Please try again.';
        break;
      case 'resource-exhausted':
        message = 'Resource limit exceeded. Please try again later.';
        break;
      case 'failed-precondition':
        message = 'Operation failed due to invalid state.';
        break;
      case 'aborted':
        message = 'Operation was aborted. Please try again.';
        break;
      case 'not-found':
        message = 'Requested resource not found.';
        break;
      case 'already-exists':
        message = 'Resource already exists.';
        break;
      default:
        message = e.message ?? 'Database operation failed. Please try again.';
    }

    return DatabaseException(message, code: e.code, details: e);
  }

  /// Check network connectivity
  static Future<bool> hasNetworkConnection() async {
    try {
      final List<ConnectivityResult> connectivityResult = 
          await Connectivity().checkConnectivity();
      
      return connectivityResult.contains(ConnectivityResult.mobile) ||
             connectivityResult.contains(ConnectivityResult.wifi) ||
             connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Log error for debugging and crash reporting
  static void logError(dynamic error, {StackTrace? stackTrace, String? context}) {
    if (kDebugMode) {
      print('$_tag: Error in $context: $error');
      if (stackTrace != null) {
        print('$_tag: Stack trace: $stackTrace');
      }
    }

    // TODO: Add crash reporting service like Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: context);
  }
}
