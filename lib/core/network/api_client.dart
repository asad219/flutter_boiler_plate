import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:dio/dio.dart';

/// Thin, typed wrapper around [Dio].
///
/// Every call returns the decoded JSON body as `Map<String, dynamic>`
/// (top-level arrays are wrapped as `{'data': [...]}`) and throws
/// [ApiException] on failure. Pair with [ApiResponseParser] to map models.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// [RequestOptions.extra] keys read by the interceptors.
  static const String requiresAuthKey = 'requiresAuth';
  static const String defaultErrorMessageKey = 'defaultErrorMessage';

  static const List<int> defaultSuccessCodes = [200, 201];

  /// `BASE_URL` + `API_VERSION`, e.g. `https://api.example.com/api/v1`.
  static String get baseUrl {
    final base = AppConstants.baseUrl;
    final version = AppConstants.apiVersion;
    if (version.isEmpty) return base;
    return base.endsWith('/') ? '$base$version' : '$base/$version';
  }

  static BaseOptions get defaultOptions => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.timeoutDuration),
    receiveTimeout: const Duration(milliseconds: AppConstants.timeoutDuration),
    sendTimeout: const Duration(milliseconds: AppConstants.timeoutDuration),
    responseType: ResponseType.json,
    headers: const {Headers.acceptHeader: Headers.jsonContentType},
  );

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    String? defaultErrorMessage,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      defaultErrorMessage: defaultErrorMessage ?? 'Request failed',
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
    String? defaultErrorMessage,
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
      defaultErrorMessage: defaultErrorMessage ?? 'Request failed',
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Object? body,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    String? defaultErrorMessage,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'PUT',
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      defaultErrorMessage: defaultErrorMessage ?? 'Update request failed',
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Object? body,
    bool requiresAuth = true,
    List<int> successCodes = defaultSuccessCodes,
    String? defaultErrorMessage,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'PATCH',
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      defaultErrorMessage: defaultErrorMessage ?? 'Update request failed',
      timeout: timeout,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Object? body,
    bool requiresAuth = true,
    List<int> successCodes = const [200, 202, 204],
    String? defaultErrorMessage,
    Duration? timeout,
    CancelToken? cancelToken,
  }) {
    return _request(
      'DELETE',
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
      successCodes: successCodes,
      defaultErrorMessage: defaultErrorMessage ?? 'Delete request failed',
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
    required String defaultErrorMessage,
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
          extra: {
            requiresAuthKey: requiresAuth,
            defaultErrorMessageKey: defaultErrorMessage,
          },
        ),
      );
      return _decodeBody(response, defaultErrorMessage);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e, fallback: defaultErrorMessage);
    }
  }

  static String _normalizePath(String endpoint) =>
      endpoint.startsWith('/') ? endpoint : '/$endpoint';

  /// Normalizes any response body into a JSON map.
  static Map<String, dynamic> _decodeBody(
    Response<dynamic> response,
    String defaultErrorMessage,
  ) {
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
        developer.log(
          'Failed to decode response body as JSON',
          name: 'ApiClient',
          error: e,
          stackTrace: stackTrace,
        );
        throw ApiException(
          statusCode: response.statusCode,
          userMessage: defaultErrorMessage,
          cause: e,
        );
      }
    }

    return {'data': data};
  }
}
