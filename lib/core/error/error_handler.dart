import 'dart:async';
import 'dart:io';

import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/error/failures.dart';
import 'package:app_boilerplate/core/network/result.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:dio/dio.dart';

/// Turns exceptions into [Failure]s.
class ErrorHandler {
  ErrorHandler._();

  static Failure toFailure(Object error, {StackTrace? stackTrace}) {
    AppLogger.warning(
      'Mapped error to Failure',
      name: 'ErrorHandler',
      error: error,
      stackTrace: stackTrace,
    );

    final exception = switch (error) {
      ApiException() => error,
      DioException() => ApiException.fromDioException(error),
      _ => null,
    };

    if (exception != null) {
      return switch (exception.type) {
        ApiErrorType.server => ServerFailure(
          message: exception.message,
          statusCode: exception.statusCode,
        ),
        ApiErrorType.unauthorized => UnauthorizedFailure(
          message: exception.message,
        ),
        ApiErrorType.noConnection => const NetworkFailure(),
        ApiErrorType.timeout => const TimeoutFailure(),
        ApiErrorType.cancelled ||
        ApiErrorType.unexpected => const UnknownFailure(),
      };
    }

    return switch (error) {
      SocketException() => const NetworkFailure(),
      TimeoutException() => const TimeoutFailure(),
      CacheException() => const CacheFailure(),
      _ => const UnknownFailure(),
    };
  }

  /// Runs [action] and returns a [Result].
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error, stackTrace) {
      return Failed(toFailure(error, stackTrace: stackTrace));
    }
  }
}
