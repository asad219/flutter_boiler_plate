import 'dart:io';

import 'package:app_boilerplate/core/error/error_handler.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.sanitizeDisplayMessage', () {
    test('rejects raw JSON and technical dumps', () {
      expect(
        ApiException.sanitizeDisplayMessage('{"statusCode":500}'),
        ApiException.defaultUserMessage,
      );
      expect(
        ApiException.sanitizeDisplayMessage(
          'SocketException: Failed host lookup',
        ),
        ApiException.defaultUserMessage,
      );
    });

    test('keeps plain human-readable messages', () {
      expect(
        ApiException.sanitizeDisplayMessage('  Email already in use  '),
        'Email already in use',
      );
    });
  });

  group('ApiException.toUserMessage', () {
    test('never surfaces low-level network errors', () {
      expect(
        ApiException.toUserMessage(
          const SocketException('boom'),
          fallback: 'x',
        ),
        'x',
      );
    });

    test('strips the Exception: prefix', () {
      expect(ApiException.toUserMessage(Exception('Nope')), 'Nope');
    });
  });

  group('ErrorHandler.toFailure', () {
    test('maps 401 to UnauthorizedFailure', () {
      final failure = ErrorHandler.toFailure(
        const ApiException(statusCode: 401, userMessage: 'Session expired'),
      );
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('maps other API errors to ServerFailure with the safe message', () {
      final failure = ErrorHandler.toFailure(
        const ApiException(statusCode: 422, userMessage: 'Invalid email'),
      );
      expect(failure, const ServerFailure('Invalid email', statusCode: 422));
    });

    test('maps connectivity errors to NetworkFailure', () {
      expect(
        ErrorHandler.toFailure(const SocketException('offline')),
        isA<NetworkFailure>(),
      );
    });
  });
}
