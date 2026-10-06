import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Typed HTTP/API error with a safe message for UI display.
///
/// Thrown by the data layer (API client, remote data sources) and converted
/// to a [Failure] by repositories via [ErrorHandler].
class ApiException implements Exception {
  const ApiException({this.statusCode, required this.userMessage, this.cause});

  final int? statusCode;
  final String userMessage;
  final Object? cause;

  static const String defaultUserMessage =
      'Something went wrong. Please try again.';
  static const String timeoutMessage = 'Request timed out';
  static const String noConnectionMessage =
      'Please check your internet connection and try again.';
  static const String sessionExpiredMessage =
      'Your session expired. Please sign in again.';
  static const String authRequiredMessage =
      'Authentication required. Please sign in again.';

  bool get isUnauthorized => statusCode == 401;

  factory ApiException.fromResponse(
    Response<dynamic>? response,
    String fallback,
  ) {
    final message = _messageFromBody(response?.data, fallback);
    return ApiException(statusCode: response?.statusCode, userMessage: message);
  }

  /// Maps any [DioException] to a user-safe [ApiException].
  factory ApiException.fromDioException(
    DioException exception, {
    String fallback = defaultUserMessage,
  }) {
    final inner = exception.error;
    if (inner is ApiException) return inner;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(userMessage: timeoutMessage, cause: exception);
      case DioExceptionType.badResponse:
        final response = exception.response;
        if (response?.statusCode == 401) {
          return ApiException(
            statusCode: 401,
            userMessage: sessionExpiredMessage,
            cause: exception,
          );
        }
        return ApiException.fromResponse(response, fallback);
      case DioExceptionType.connectionError:
        return ApiException(userMessage: noConnectionMessage, cause: exception);
      case DioExceptionType.unknown:
        if (inner is SocketException) {
          return ApiException(
            userMessage: noConnectionMessage,
            cause: exception,
          );
        }
        return ApiException(userMessage: fallback, cause: exception);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return ApiException(userMessage: fallback, cause: exception);
    }
  }

  /// Extracts a short, human-readable message from an API error body.
  /// Never returns raw JSON payloads or technical dumps.
  static String _messageFromBody(Object? body, String fallback) {
    if (body == null) return fallback;
    if (body is String) {
      if (body.isEmpty) return fallback;
      try {
        final decoded = jsonDecode(body);
        final extracted = _extractMessage(decoded);
        return sanitizeDisplayMessage(extracted, fallback: fallback);
      } catch (_) {
        // Body is not JSON — never show raw response text.
        return fallback;
      }
    }
    return sanitizeDisplayMessage(_extractMessage(body), fallback: fallback);
  }

  /// Pulls the best user-facing string from common Nest/Zod error shapes.
  static String? _extractMessage(Object? json) {
    if (json == null) return null;

    if (json is String) {
      final trimmed = json.trim();
      if (trimmed.isEmpty) return null;
      // Sometimes APIs stringify a JSON error array/object into `message`.
      if (_looksLikeJson(trimmed)) {
        try {
          return _extractMessage(jsonDecode(trimmed));
        } catch (_) {
          return null;
        }
      }
      return trimmed;
    }

    if (json is List) {
      for (final item in json) {
        final message = _extractMessage(item);
        if (message != null && message.isNotEmpty) return message;
      }
      return null;
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      // Prefer field-level validation messages.
      final nested =
          _extractMessage(map['message']) ??
          _extractMessage(map['error']) ??
          _extractMessage(map['detail']) ??
          _extractMessage(map['errors']);
      if (nested != null && nested.isNotEmpty) return nested;

      return null;
    }

    return null;
  }

  /// Maps any caught error to a user-safe message for BLoC/UI layers.
  static String toUserMessage(
    Object error, {
    String fallback = defaultUserMessage,
  }) {
    if (error is ApiException) {
      return sanitizeDisplayMessage(error.userMessage, fallback: fallback);
    }

    if (error is DioException) {
      return sanitizeDisplayMessage(
        ApiException.fromDioException(error, fallback: fallback).userMessage,
        fallback: fallback,
      );
    }

    // Network / filesystem / timeout failures must never surface internals.
    if (error is SocketException ||
        error is HttpException ||
        error is HandshakeException ||
        error is TlsException ||
        error is FileSystemException ||
        error is IOException ||
        error is TimeoutException ||
        error is FormatException) {
      return fallback;
    }

    if (error is Exception || error is Error) {
      final raw = error.toString();
      const prefixes = ['Exception: ', 'Error: ', 'Bad state: '];
      var message = raw;
      for (final prefix in prefixes) {
        if (message.startsWith(prefix)) {
          message = message.substring(prefix.length);
          break;
        }
      }
      return sanitizeDisplayMessage(message, fallback: fallback);
    }

    return fallback;
  }

  /// Final guard for any string about to be shown in UI (toast, screen, etc.).
  static String sanitizeDisplayMessage(
    String? message, {
    String fallback = defaultUserMessage,
  }) {
    if (message == null) return fallback;
    final trimmed = message.trim();
    if (trimmed.isEmpty) return fallback;
    if (_looksTechnical(trimmed)) return fallback;
    return trimmed;
  }

  static bool _looksLikeJson(String value) {
    final trimmed = value.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  static bool _looksTechnical(String message) {
    if (_looksLikeJson(message)) return true;

    final lower = message.toLowerCase();
    const technicalMarkers = [
      'filesystemexception',
      'socketexception',
      'httpexception',
      'clientexception',
      'dioexception',
      'timeoutexception',
      'formatexception',
      'handshakeexception',
      'tlsexception',
      'path =',
      'stack trace',
      '#0 ',
      'errno =',
      '"origin"',
      '"statuscode"',
      '"pattern"',
      'invalid_format',
    ];

    for (final marker in technicalMarkers) {
      if (lower.contains(marker)) return true;
    }

    // Long dumps with many braces/quotes are almost never user copy.
    final braceCount =
        '{'.allMatches(message).length +
        '}'.allMatches(message).length +
        '['.allMatches(message).length +
        ']'.allMatches(message).length;
    if (braceCount >= 4 && message.contains('"')) return true;

    return false;
  }

  @override
  String toString() => userMessage;
}

/// Thrown by local data sources when reading/writing persisted data fails.
class CacheException implements Exception {
  const CacheException([this.message = 'Failed to access local data.']);

  final String message;

  @override
  String toString() => message;
}
