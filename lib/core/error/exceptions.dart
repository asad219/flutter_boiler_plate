import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Error types. The UI shows a translated message for each one.
enum ApiErrorType {
  /// The server returned an error (4xx / 5xx).
  server,

  /// 401: wrong or expired login.
  unauthorized,

  /// No internet, or the server can't be reached.
  noConnection,

  /// The request took too long.
  timeout,

  /// Cancelled with a `CancelToken`.
  cancelled,

  /// Bad response or any other error.
  unexpected,
}

/// Error thrown by the data layer. Repositories turn it into a `Failure`.
class ApiException implements Exception {
  const ApiException({
    this.type = ApiErrorType.server,
    this.statusCode,
    this.message,
    this.cause,
  });

  final ApiErrorType type;
  final int? statusCode;

  /// Message from the server (e.g. "Email already taken"). When `null`, the
  /// app shows its own message.
  final String? message;

  /// Original error, for logs only.
  final Object? cause;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  factory ApiException.fromResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    return ApiException(
      type: statusCode == 401 ? ApiErrorType.unauthorized : ApiErrorType.server,
      statusCode: statusCode,
      message: _messageFromBody(response?.data),
    );
  }

  /// Converts a [DioException].
  factory ApiException.fromDioException(DioException exception) {
    final inner = exception.error;
    if (inner is ApiException) return inner;

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiException(
        type: ApiErrorType.timeout,
        cause: exception,
      ),
      DioExceptionType.badResponse => ApiException.fromResponse(
        exception.response,
      ),
      DioExceptionType.connectionError => ApiException(
        type: ApiErrorType.noConnection,
        cause: exception,
      ),
      DioExceptionType.cancel => ApiException(
        type: ApiErrorType.cancelled,
        cause: exception,
      ),
      DioExceptionType.unknown when inner is SocketException => ApiException(
        type: ApiErrorType.noConnection,
        cause: exception,
      ),
      DioExceptionType.unknown || DioExceptionType.badCertificate =>
        ApiException(type: ApiErrorType.unexpected, cause: exception),
    };
  }

  /// Gets a short message from an error body. Never returns raw JSON.
  static String? _messageFromBody(Object? body) {
    if (body is String) {
      if (body.isEmpty) return null;
      try {
        return sanitize(_extractMessage(jsonDecode(body)));
      } catch (_) {
        // Not JSON (maybe an HTML page), so don't show it.
        return null;
      }
    }
    return sanitize(_extractMessage(body));
  }

  /// Finds the message in common formats: `message`, `error`, `detail`,
  /// `errors`.
  static String? _extractMessage(Object? json) {
    if (json == null) return null;

    if (json is String) {
      final trimmed = json.trim();
      if (trimmed.isEmpty) return null;
      // Some APIs put JSON as a string inside `message`.
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
      return _extractMessage(json['message']) ??
          _extractMessage(json['error']) ??
          _extractMessage(json['detail']) ??
          _extractMessage(json['errors']);
    }

    return null;
  }

  /// Returns [message] if it's OK to show to users, otherwise `null`.
  static String? sanitize(String? message) {
    final trimmed = message?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (_looksTechnical(trimmed)) return null;
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

    // Lots of brackets and quotes means data, not a message.
    final braceCount =
        '{'.allMatches(message).length +
        '}'.allMatches(message).length +
        '['.allMatches(message).length +
        ']'.allMatches(message).length;
    return braceCount >= 4 && message.contains('"');
  }

  @override
  String toString() =>
      'ApiException(type: ${type.name}, statusCode: $statusCode, '
      'message: $message, cause: $cause)';
}

/// Thrown when reading or saving local data fails.
class CacheException implements Exception {
  const CacheException([this.message = 'Failed to access local data.']);

  /// For logs only, not shown to users.
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
