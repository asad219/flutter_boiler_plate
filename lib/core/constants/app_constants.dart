import 'package:flutter/services.dart';

/// Constants that are the same in every environment. Per-environment values
/// are in `EnvConfig`.
class AppConstants {
  AppConstants._();

  /// Shown in the app switcher and on the splash screen. The name under the
  /// icon is set in `AndroidManifest.xml` and `Info.plist`.
  static const String appName = 'App Boilerplate';

  /// Timeout for HTTP requests.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Also update `UISupportedInterfaceOrientations` in `ios/Runner/Info.plist`.
  static const List<DeviceOrientation> orientations = [
    DeviceOrientation.portraitUp,
  ];
}
