/// Compile-time configuration injected via `--dart-define-from-file`.
///
/// Example:
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

  /// Lets an app run without Firebase config files (e.g. CI, early dev).
  static const bool enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  static void validate() {
    if (baseUrl.isEmpty) {
      throw StateError(
        'BASE_URL is not set. Run with --dart-define-from-file=env/dev.json '
        '(copy env/dev.json.example to env/dev.json first).',
      );
    }
  }
}
