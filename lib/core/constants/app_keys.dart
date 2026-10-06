/// Storage keys for secure storage and shared preferences.
class AppKeys {
  AppKeys._();

  // Secure storage
  static const String userAuthTokenKey = 'userAuthToken';
  static const String userRefreshTokenKey = 'userRefreshToken';

  // Shared preferences
  static const String cachedUserKey = 'cachedUser';
  static const String fcmTokenKey = 'fcmToken';
  static const String themeModeKey = 'themeMode';
  static const String localeKey = 'locale';
}
