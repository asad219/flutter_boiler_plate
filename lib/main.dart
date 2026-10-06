import 'dart:async';
import 'dart:ui';

import 'package:app_boilerplate/app/app.dart';
import 'package:app_boilerplate/core/config/env_config.dart';
import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.validate();
  _registerGlobalErrorHandlers();

  // Firebase is optional: disabled via ENABLE_FIREBASE=false or missing config.
  if (await FirebaseBootstrap.initialize()) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await setupLocator();
  await getIt<SecureTokenService>().warmCache();

  final pushService = getIt<PushNotificationService>();
  await pushService.initialize();
  // Don't block runApp on the OS permission dialog.
  unawaited(pushService.requestPermission());

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}

void _registerGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'Flutter framework error',
      name: 'main',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error(
      'Uncaught async error',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
}
