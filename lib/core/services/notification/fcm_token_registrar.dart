import 'dart:developer' as developer;
import 'dart:io';

import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';

/// Sends the device's FCM token to the backend for the signed-in user.
///
/// Expected backend contract: `POST /devices {token, platform}` (upsert).
/// The backend should drop the token on `/users/logout`.
class FcmTokenRegistrar {
  FcmTokenRegistrar(this._apiClient, this._tokenService);

  final ApiClient _apiClient;
  final SecureTokenService _tokenService;

  Future<void> register(String fcmToken) async {
    if (!await _tokenService.hasAuthToken()) return;

    try {
      await _apiClient.post(
        ApiEndpoints.registerDevice,
        body: {'token': fcmToken, 'platform': Platform.operatingSystem},
        defaultErrorMessage: 'Failed to register device',
      );
    } catch (e, stackTrace) {
      developer.log(
        'FCM token registration failed',
        name: 'FcmTokenRegistrar',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
