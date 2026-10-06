import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Sends errors to Firebase Crashlytics. Does nothing in debug builds or when
/// Firebase isn't set up.
class CrashReporter {
  CrashReporter._();

  static FirebaseCrashlytics? get _crashlytics =>
      FirebaseBootstrap.isInitialized && !kDebugMode
      ? FirebaseCrashlytics.instance
      : null;

  /// Call once after Firebase is initialized.
  static Future<void> initialize() async {
    if (!FirebaseBootstrap.isInitialized) return;
    await _guard(
      () => FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      ),
    );
  }

  static Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _guard(
      () => crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      ),
    );
  }

  /// Flutter UI errors don't close the app, so they're non-fatal by default.
  static Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _guard(() => crashlytics.recordFlutterError(details, fatal: fatal));
  }

  /// Links crashes to a user. Pass `null` on logout. Use the user id, not the
  /// email or name.
  static Future<void> setUserId(String? userId) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _guard(() => crashlytics.setUserIdentifier(userId ?? ''));
  }

  /// Adds a note to the next crash report.
  static Future<void> log(String message) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    await _guard(() => crashlytics.log(message));
  }

  // Never let crash reporting crash the app.
  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}
