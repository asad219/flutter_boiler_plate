/// Values from the env file:
/// `flutter run --dart-define-from-file=env/dev.json`
class EnvConfig {
  EnvConfig._();

  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );
  static const String baseUrl = String.fromEnvironment('BASE_URL');
  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  /// Set to false to run without Firebase.
  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  /// Error message if the config is wrong, or `null` if it's fine.
  /// The app shows it on a setup screen at startup.
  static String? get configurationError {
    if (baseUrl.isEmpty) {
      return 'BASE_URL is not set.\n\n'
          'Copy env/dev.json.example to env/dev.json, set BASE_URL, then run:\n'
          'flutter run --dart-define-from-file=env/dev.json';
    }
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'BASE_URL "$baseUrl" is not a valid URL.\n\n'
          'Use a full URL such as https://api.example.com';
    }
    return null;
  }
}
