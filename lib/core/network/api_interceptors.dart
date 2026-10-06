import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/network/api_response_parser.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Adds the token to requests. On a 401 it refreshes the token once and
/// retries. If that isn't possible, the user is signed out.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._tokenService,
    required this._sessionExpiredNotifier,
    Dio? refreshDio,
  }) : // Plain Dio without interceptors, so refresh calls don't loop.
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
            type: ApiErrorType.unauthorized,
            statusCode: 401,
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
      AppLogger.warning(
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

/// Turns every Dio error into an [ApiException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: ApiException.fromDioException(err)));
  }
}

/// Logs requests in debug builds. Passwords and tokens are hidden.
class LoggingInterceptor extends Interceptor {
  static const String _startTimeKey = 'requestStartTime';
  static const String _mask = '***';

  /// Keys (lower case) whose values are hidden in logs.
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'password',
    'currentpassword',
    'newpassword',
    'confirmpassword',
    'token',
    'accesstoken',
    'refreshtoken',
    'otp',
    'pin',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now();
    final body = options.data == null ? '' : '\nbody: ${_redact(options.data)}';
    AppLogger.debug(
      '→ ${options.method} ${options.uri}\n'
      'headers: ${_redact(options.headers)}$body',
      name: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.debug(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} ${_elapsed(response.requestOptions)}',
      name: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.warning(
      '✕ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      '${_elapsed(err.requestOptions)}',
      name: 'HTTP',
      error: err.error ?? err.message,
    );
    handler.next(err);
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key: _sensitiveKeys.contains('${entry.key}'.toLowerCase())
              ? _mask
              : _redact(entry.value),
      };
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  static String _elapsed(RequestOptions options) {
    final start = options.extra[_startTimeKey];
    if (start is! DateTime) return '';
    return '(${DateTime.now().difference(start).inMilliseconds}ms)';
  }
}
