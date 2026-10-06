import 'package:app_boilerplate/core/config/env_config.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'App Boilerplate';
  static String get baseUrl => EnvConfig.baseUrl;
  static String get apiVersion => EnvConfig.apiVersion;

  /// Default HTTP timeout. 5s is too aggressive on slow/mobile networks.
  static const int timeoutDuration = 20000; // in milliseconds
  static const String connectivityCheckHost = 'google.com';
}
