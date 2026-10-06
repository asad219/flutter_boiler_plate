import 'dart:developer' as developer;
import 'dart:io';

import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/error/failures.dart';
import 'package:app_boilerplate/core/network/result.dart';
import 'package:dio/dio.dart';

/// Converts data-layer exceptions into domain [Failure]s.
class ErrorHandler {
  ErrorHandler._();

  static Failure toFailure(
    Object error, {
    StackTrace? stackTrace,
    String fallback = ApiException.defaultUserMessage,
  }) {
    developer.log(
      'Mapped error to Failure',
      name: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    final exception = switch (error) {
      ApiException() => error,
      DioException() => ApiException.fromDioException(
        error,
        fallback: fallback,
      ),
      _ => null,
    };

    if (exception != null) {
      if (exception.isUnauthorized) {
        return UnauthorizedFailure(
          ApiException.sanitizeDisplayMessage(
            exception.userMessage,
            fallback: ApiException.sessionExpiredMessage,
          ),
        );
      }
      if (exception.userMessage == ApiException.noConnectionMessage) {
        return const NetworkFailure();
      }
      return ServerFailure(
        ApiException.toUserMessage(exception, fallback: fallback),
        statusCode: exception.statusCode,
      );
    }

    if (error is SocketException) return const NetworkFailure();
    if (error is CacheException) return CacheFailure(error.message);

    return UnknownFailure(
      ApiException.toUserMessage(error, fallback: fallback),
    );
  }

  /// Runs [action] and wraps the outcome in a [Result].
  static Future<Result<T>> guard<T>(
    Future<T> Function() action, {
    String fallback = ApiException.defaultUserMessage,
  }) async {
    try {
      return Success(await action());
    } catch (error, stackTrace) {
      return Failed(
        toFailure(error, stackTrace: stackTrace, fallback: fallback),
      );
    }
  }
}
