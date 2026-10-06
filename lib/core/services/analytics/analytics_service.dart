import 'dart:developer' as developer;

import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Firebase Analytics wrapper. Becomes a no-op when Firebase isn't initialized
/// so callers never need to guard.
class AnalyticsService {
  FirebaseAnalytics? get _analytics =>
      FirebaseBootstrap.isInitialized ? FirebaseAnalytics.instance : null;

  /// Add to `MaterialApp.navigatorObservers` for automatic screen tracking.
  NavigatorObserver? get navigatorObserver {
    final analytics = _analytics;
    return analytics == null
        ? null
        : FirebaseAnalyticsObserver(analytics: analytics);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _run((a) => a.logEvent(name: name, parameters: parameters));
  }

  Future<void> logScreenView(String screenName) {
    return _run((a) => a.logScreenView(screenName: screenName));
  }

  Future<void> logLogin({String method = 'email'}) {
    return _run((a) => a.logLogin(loginMethod: method));
  }

  Future<void> setUserId(String? userId) {
    return _run((a) => a.setUserId(id: userId));
  }

  Future<void> setUserProperty(String name, String? value) {
    return _run((a) => a.setUserProperty(name: name, value: value));
  }

  Future<void> _run(
    Future<void> Function(FirebaseAnalytics analytics) action,
  ) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await action(analytics);
    } catch (e, stackTrace) {
      developer.log(
        'Analytics call failed',
        name: 'AnalyticsService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
