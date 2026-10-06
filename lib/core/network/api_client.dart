import 'dart:convert';

import 'package:app_boilerplate/core/config/env_config.dart';
import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Small wrapper around [Dio]. Every call returns the JSON body as a map (a
/// list comes back as `{'data': [...]}`) and throws [ApiException] on errors.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// Keys in [RequestOptions.extra] used by the interceptors.
  static const String requiresAuthKey = 'requiresAuth';

  static const List<int> defaultSuccessCodes = [200, 201];

  /// `BASE_URL` + `API_VERSION`, e.g. `https://api.example.com/api/v1`.
  static String get baseUrl {
    const base = EnvConfig.baseUrl;
    const version = EnvConfig.apiVersion;
    if (version.isEmpty) return base;
    return base.endsWith('/') ? '$base$version' : '$base/$version';
  }

  static BaseOptions get defaultOptions => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: AppConstants.requestTimeout,
    receiveTimeout: AppConstants.requestTimeout,
    sendTimeout: AppConstants.requestTimeout,
    responseType: ResponseType.json,
    headers: const {Headers.acceptHeader: Headers.jsonContentType},
  );

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'POST',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'PUT',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'PATCH',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = const [200, 202, 204],
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'DELETE',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    required bool requiresAuth,
    required List<int> successCodes,
    Duration? timeout,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        _normalizePath(endpoint),
        data: body,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          receiveTimeout: timeout,
          sendTimeout: body != null ? timeout : null,
          validateStatus: (status) =>
              status != null && successCodes.contains(status),
          extra: {requiresAuthKey: requiresAuth},
        ),
      );
      return _decodeBody(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static String _normalizePath(String endpoint) =>
      endpoint.startsWith('/') ? endpoint : '/$endpoint';

  /// Turns any response body into a map.
  static Map<String, dynamic> _decodeBody(Response<dynamic> response) {
    final data = response.data;
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'data': data};

    if (data is String) {
      if (data.isEmpty) return {};
      try {
        final json = jsonDecode(data);
        if (json is Map<String, dynamic>) return json;
        return {'data': json};
      } catch (e, stackTrace) {
        AppLogger.error(
          'Failed to decode response body as JSON',
          name: 'ApiClient',
          error: e,
          stackTrace: stackTrace,
        );
        throw ApiException(
          type: ApiErrorType.unexpected,
          statusCode: response.statusCode,
          cause: e,
        );
      }
    }

    return {'data': data};
  }
}
