import 'dart:developer' as developer;

import 'package:app_boilerplate/core/config/env_config.dart';
import 'package:firebase_core/firebase_core.dart';

/// Guards Firebase initialization so the app still boots when Firebase is
/// disabled (`ENABLE_FIREBASE=false`) or native config files are missing.
///
/// Every Firebase-backed service must check [isInitialized] first.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Safe to call multiple times and from background isolates.
  static Future<bool> initialize() async {
    if (_initialized) return true;

    if (!EnvConfig.enableFirebase) {
      developer.log(
        'Firebase disabled via ENABLE_FIREBASE=false',
        name: 'FirebaseBootstrap',
      );
      return false;
    }

    try {
      // Reads google-services.json (Android) / GoogleService-Info.plist (iOS).
      // To use FlutterFire CLI instead, pass
      // `options: DefaultFirebaseOptions.currentPlatform` here.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _initialized = true;
    } catch (e, stackTrace) {
      developer.log(
        'Firebase not configured — continuing without Firebase services. '
        'See README › Firebase setup.',
        name: 'FirebaseBootstrap',
        error: e,
        stackTrace: stackTrace,
      );
      _initialized = false;
    }
    return _initialized;
  }
}
