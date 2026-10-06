import 'package:app_boilerplate/core/error/exceptions.dart';

/// Helpers to read models from API responses.
class ApiResponseParser {
  ApiResponseParser._();

  static dynamic unwrapData(Map<String, dynamic> json) => json['data'] ?? json;

  static T parseObject<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final decoded = unwrapData(json);

    if (decoded is Map<String, dynamic>) {
      return fromJson(decoded);
    }

    throw const ApiException(type: ApiErrorType.unexpected);
  }

  static List<T> parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final decoded = unwrapData(json);

    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }

    throw const ApiException(type: ApiErrorType.unexpected);
  }

  static List<T> parseListOrSingle<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final decoded = unwrapData(json);

    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
    }

    if (decoded is Map<String, dynamic>) {
      return [fromJson(decoded)];
    }

    throw const ApiException(type: ApiErrorType.unexpected);
  }
}
