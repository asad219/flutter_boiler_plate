import 'dart:convert';
import 'dart:typed_data';

import 'package:app_boilerplate/core/services/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [SecureStorageService] for tests.
class FakeSecureStorageService extends Fake implements SecureStorageService {
  final Map<String, String> values = {};

  @override
  Future<void> writeString({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async => values.clear();
}

typedef FakeRoute = ResponseBody Function(RequestOptions options);

/// Routes Dio requests to [handler] instead of the network.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final FakeRoute handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
