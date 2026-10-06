import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/network/api_interceptors.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeSecureStorageService storage;
  late SecureTokenService tokenService;
  late SessionExpiredNotifier notifier;

  ApiClient buildClient(FakeHttpAdapter adapter) {
    final options = BaseOptions(baseUrl: 'https://test.local/api/v1');
    final refreshDio = Dio(options)..httpClientAdapter = adapter;
    final dio = Dio(options)
      ..httpClientAdapter = adapter
      ..interceptors.addAll([
        AuthInterceptor(
          tokenService: tokenService,
          sessionExpiredNotifier: notifier,
          refreshDio: refreshDio,
        ),
        ErrorInterceptor(),
      ]);
    return ApiClient(dio);
  }

  setUp(() {
    storage = FakeSecureStorageService();
    tokenService = SecureTokenService(storage);
    notifier = SessionExpiredNotifier();
  });

  tearDown(() => notifier.dispose());

  test('injects the bearer token on authenticated requests', () async {
    await tokenService.saveTokens(accessToken: 'abc');
    final adapter = FakeHttpAdapter((_) => jsonResponse({'ok': true}));

    final json = await buildClient(adapter).get('/users/me');

    expect(json, {'ok': true});
    expect(adapter.requests.single.headers['Authorization'], 'Bearer abc');
  });

  test('wraps top-level arrays as {data: [...]}', () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse([1, 2]));

    final json = await buildClient(adapter).get('/items', requiresAuth: false);

    expect(json, {
      'data': [1, 2],
    });
  });

  test(
    'throws auth-required without hitting the network when no token',
    () async {
      final adapter = FakeHttpAdapter((_) => jsonResponse({}));

      await expectLater(
        buildClient(adapter).get('/users/me'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having(
                (e) => e.userMessage,
                'message',
                ApiException.authRequiredMessage,
              ),
        ),
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test('extracts a user-safe message from an error body', () async {
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({
        'message': [
          {'message': 'Invalid credentials'},
        ],
      }, status: 400),
    );

    await expectLater(
      buildClient(adapter).post(ApiEndpoints.login, requiresAuth: false),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.userMessage, 'message', 'Invalid credentials'),
      ),
    );
  });

  test('refreshes the token on 401 and retries the request', () async {
    await tokenService.saveTokens(accessToken: 'old', refreshToken: 'refresh');
    final adapter = FakeHttpAdapter((options) {
      if (options.path == ApiEndpoints.refreshToken) {
        return jsonResponse({'token': 'new', 'refreshToken': 'refresh2'});
      }
      return options.headers['Authorization'] == 'Bearer new'
          ? jsonResponse({'id': '1'})
          : jsonResponse({'message': 'Unauthorized'}, status: 401);
    });

    final json = await buildClient(adapter).get('/users/me');

    expect(json, {'id': '1'});
    expect(await tokenService.getAuthToken(), 'new');
    expect(storage.values[AppKeys.userRefreshTokenKey], 'refresh2');
  });

  test('expires the session on 401 when refresh is not possible', () async {
    await tokenService.saveTokens(accessToken: 'old');
    final adapter = FakeHttpAdapter(
      (_) => jsonResponse({'message': 'Unauthorized'}, status: 401),
    );
    final expired = expectLater(notifier.stream, emits(null));

    await expectLater(
      buildClient(adapter).get('/users/me'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
    await expired;
    expect(await tokenService.hasAuthToken(), isFalse);
  });
}
