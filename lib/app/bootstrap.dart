import 'dart:async';
import 'dart:ui';

import 'package:app_boilerplate/app/app.dart';
import 'package:app_boilerplate/core/config/env_config.dart';
import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/services/crash/crash_reporter.dart';
import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Startup steps, in order. Add new startup code here.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerGlobalErrorHandlers();

  final configError = EnvConfig.configurationError;
  if (configError != null) {
    runApp(_ConfigErrorApp(message: configError));
    return;
  }

  // Skipped when ENABLE_FIREBASE is false or the config files are missing.
  if (await FirebaseBootstrap.initialize()) {
    await CrashReporter.initialize();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  await setupLocator();
  await getIt<SecureTokenService>().warmCache();

  final pushService = getIt<PushNotificationService>();
  await pushService.initialize();
  // Don't wait for the permission dialog.
  unawaited(pushService.requestPermission());

  await SystemChrome.setPreferredOrientations(AppConstants.orientations);

  runApp(const App());
}

void _registerGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(CrashReporter.recordFlutterError(details));
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error(
      'Uncaught error',
      name: 'bootstrap',
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
    return true;
  };
}

/// Shown when the env file is missing or wrong. Kept simple because nothing
/// else is set up yet.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.settings_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Configuration error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                SelectableText(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
