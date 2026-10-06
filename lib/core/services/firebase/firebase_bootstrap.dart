import 'package:app_boilerplate/core/config/env_config.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';

/// Starts Firebase if it's enabled and set up. Firebase services check
/// [isInitialized] first, so the app also works without Firebase.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Safe to call more than once, also from background handlers.
  static Future<bool> initialize() async {
    if (_initialized) return true;

    if (!EnvConfig.enableFirebase) {
      AppLogger.debug(
        'Firebase disabled via ENABLE_FIREBASE=false',
        name: 'FirebaseBootstrap',
      );
      return false;
    }

    try {
      // Reads google-services.json / GoogleService-Info.plist. With the
      // FlutterFire CLI, pass `options: DefaultFirebaseOptions.currentPlatform`.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _initialized = true;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Firebase is not set up, so it is skipped. '
        'See "Firebase setup" in README.md.',
        name: 'FirebaseBootstrap',
        error: e,
        stackTrace: stackTrace,
      );
      _initialized = false;
    }
    return _initialized;
  }
}
