import 'dart:io';

import 'package:app_boilerplate/core/constants/api_endpoints.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';

/// Sends the FCM token to the backend (`POST /devices {token, platform}`).
/// The backend should remove the token on logout.
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
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'FCM token registration failed',
        name: 'FcmTokenRegistrar',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
