/// Relative API paths. The base URL and version come from [EnvConfig].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/users/login';
  static const String logout = '/users/logout';
  static const String refreshToken = '/users/refresh-token';
  static const String currentUser = '/users/me';

  // Devices (FCM)
  static const String registerDevice = '/devices';
}
