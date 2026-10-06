import 'dart:developer' as developer;

import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/network/api_response_parser.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:dio/dio.dart';

/// Injects the bearer token and transparently refreshes it on 401.
///
/// Queued so concurrent 401s trigger a single refresh; requests that failed
/// with an already-replaced token are simply retried with the new one.
/// When no refresh is possible the session is cleared and
/// [SessionExpiredNotifier] fires.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenService,
    required this._sessionExpiredNotifier,
    Dio? refreshDio,
  }) : // Interceptor-free client so refresh/retry calls never re-enter this queue.
       _plainDio = refreshDio ?? Dio(ApiClient.defaultOptions);

  final SecureTokenService _tokenService;
  final SessionExpiredNotifier _sessionExpiredNotifier;
  final Dio _plainDio;

  static const String _authHeader = 'Authorization';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_requiresAuth(options)) return handler.next(options);

    final token = await _tokenService.getAuthToken();
    if (token.isEmpty) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const ApiException(
            statusCode: 401,
            userMessage: ApiException.authRequiredMessage,
          ),
        ),
      );
    }

    options.headers[_authHeader] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 || !_requiresAuth(options)) {
      return handler.next(err);
    }

    final failedToken = _bearerFrom(options.headers[_authHeader]);
    final currentToken = await _tokenService.getAuthToken();

    final newToken = (currentToken.isNotEmpty && currentToken != failedToken)
        ? currentToken
        : await _refreshAccessToken();

    if (newToken == null) {
      await _expireSession();
      return handler.next(err);
    }

    try {
      options.headers[_authHeader] = 'Bearer $newToken';
      final response = await _plainDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      if (retryError.response?.statusCode == 401) await _expireSession();
      handler.next(retryError);
    }
  }

  /// Returns the new access token, or `null` if refresh isn't possible.
  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken.isEmpty) return null;

    try {
      final response = await _plainDio.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) return null;

      final payload = ApiResponseParser.unwrapData(body);
      if (payload is! Map<String, dynamic>) return null;

      final accessToken =
          (payload['token'] ?? payload['accessToken']) as String? ?? '';
      if (accessToken.isEmpty) return null;

      await _tokenService.saveTokens(
        accessToken: accessToken,
        refreshToken: payload['refreshToken'] as String?,
      );
      return accessToken;
    } catch (e, stackTrace) {
      developer.log(
        'Token refresh failed',
        name: 'AuthInterceptor',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _expireSession() async {
    await _tokenService.clearTokens();
    _sessionExpiredNotifier.notify();
  }

  static bool _requiresAuth(RequestOptions options) =>
      options.extra[ApiClient.requiresAuthKey] == true;

  static String? _bearerFrom(Object? header) {
    if (header is! String) return null;
    return header.startsWith('Bearer ') ? header.substring(7) : header;
  }
}

/// Normalizes every [DioException] so `error` is a user-safe [ApiException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final fallback =
        err.requestOptions.extra[ApiClient.defaultErrorMessageKey] as String? ??
        ApiException.defaultUserMessage;
    handler.next(
      err.copyWith(
        error: ApiException.fromDioException(err, fallback: fallback),
      ),
    );
  }
}

/// Debug-only request/response logging with sensitive headers redacted.
class LoggingInterceptor extends Interceptor {
  static const String _startTimeKey = 'requestStartTime';
  static const Set<String> _redactedHeaders = {'authorization', 'cookie'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    final headers = {
      for (final entry in options.headers.entries)
        entry.key: _redactedHeaders.contains(entry.key.toLowerCase())
            ? '***'
            : entry.value,
    };
    developer.log(
      '→ ${options.method} ${options.uri}\nheaders: $headers'
      '${options.data != null ? '\nbody: ${options.data}' : ''}',
      name: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} ${_elapsed(response.requestOptions)}',
      name: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '${_elapsed(err.requestOptions)}',
      name: 'HTTP',
      error: err.error ?? err.message,
    );
    handler.next(err);
  }

  static String _elapsed(RequestOptions options) {
    final start = options.extra[_startTimeKey];
    if (start is! DateTime) return '';
    return '(${DateTime.now().difference(start).inMilliseconds}ms)';
  }
}
