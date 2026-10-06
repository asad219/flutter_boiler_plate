import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Minimal logger over `dart:developer` — silent in release builds.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String name = 'App'}) {
    if (kReleaseMode) return;
    developer.log(message, name: name);
  }

  static void error(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
