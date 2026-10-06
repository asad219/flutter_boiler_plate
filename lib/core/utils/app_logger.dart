import 'dart:async';
import 'dart:developer' as developer;

import 'package:app_boilerplate/core/services/crash/crash_reporter.dart';
import 'package:flutter/foundation.dart';

/// Use this instead of `print`.
///
/// - [debug] and [warning] only print in debug builds.
/// - [error] always prints and is sent to Crashlytics.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String name = 'App'}) {
    if (kReleaseMode) return;
    developer.log(message, name: name, level: 500);
  }

  static void warning(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }

  static void error(
    String message, {
    String name = 'App',
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    unawaited(
      CrashReporter.recordError(
        error ?? message,
        stackTrace ?? StackTrace.current,
        reason: '[$name] $message',
        fatal: fatal,
      ),
    );
  }
}
