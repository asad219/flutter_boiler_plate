import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/services/storage/secure_storage_service.dart';
import 'package:flutter/services.dart';

/// Single entry point for reading, writing, and clearing auth tokens.
class SecureTokenService {
  SecureTokenService(this._secureStorage);

  final SecureStorageService _secureStorage;

  /// In-process cache so API calls while the device is locked / backgrounded
  /// do not depend on Keystore/Keychain (which can hang or fail when locked).
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  static const Duration _secureReadTimeout = Duration(seconds: 2);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await _secureStorage.writeString(
      key: AppKeys.userAuthTokenKey,
      value: accessToken,
    );
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _cachedRefreshToken = refreshToken;
      await _secureStorage.writeString(
        key: AppKeys.userRefreshTokenKey,
        value: refreshToken,
      );
    }
  }

  Future<String> getAuthToken() async {
    final cached = _cachedAccessToken;
    if (cached != null && cached.isNotEmpty) return cached;

    final stored = await _safeRead(AppKeys.userAuthTokenKey);
    if (stored.isNotEmpty) _cachedAccessToken = stored;
    return stored;
  }

  Future<String> getRefreshToken() async {
    final cached = _cachedRefreshToken;
    if (cached != null && cached.isNotEmpty) return cached;

    final stored = await _safeRead(AppKeys.userRefreshTokenKey);
    if (stored.isNotEmpty) _cachedRefreshToken = stored;
    return stored;
  }

  Future<bool> hasAuthToken() async => (await getAuthToken()).isNotEmpty;

  /// Warm the in-memory cache while the device is unlocked.
  Future<void> warmCache() async {
    await Future.wait([getAuthToken(), getRefreshToken()]);
  }

  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await Future.wait([
      _secureStorage.delete(AppKeys.userAuthTokenKey),
      _secureStorage.delete(AppKeys.userRefreshTokenKey),
    ]);
  }

  Future<String> _safeRead(String key) async {
    try {
      final value = await _secureStorage
          .readString(key)
          .timeout(_secureReadTimeout);
      return value ?? '';
    } on PlatformException {
      return '';
    } catch (_) {
      // Timeout / Keystore unavailable while locked.
      return '';
    }
  }
}
