import 'dart:convert';

import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:app_boilerplate/features/auth/data/models/user_model.dart';

/// Tokens live in secure storage; the non-sensitive profile in preferences.
/// Throws [CacheException] on failure.
abstract interface class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, String? refreshToken});

  Future<bool> hasSession();

  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    required this._tokenService,
    required this._prefs,
  });

  final SecureTokenService _tokenService;
  final SharedPreferencesService _prefs;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _tokenService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (_) {
      throw const CacheException('Failed to save your session.');
    }
  }

  @override
  Future<bool> hasSession() => _tokenService.hasAuthToken();

  @override
  Future<void> cacheUser(UserModel user) async {
    final saved = await _prefs.setString(
      AppKeys.cachedUserKey,
      jsonEncode(user.toJson()),
    );
    if (!saved) throw const CacheException();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final raw = _prefs.getString(AppKeys.cachedUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return UserModel.fromJson(decoded);
    } catch (_) {
      await _prefs.remove(AppKeys.cachedUserKey);
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _tokenService.clearTokens(),
      _prefs.remove(AppKeys.cachedUserKey),
    ]);
  }
}
