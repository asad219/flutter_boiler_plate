import 'dart:async';
import 'dart:io';

import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:app_boilerplate/core/services/notification/fcm_token_registrar.dart';
import 'package:app_boilerplate/core/services/notification/local_notification_service.dart';
import 'package:app_boilerplate/core/services/notification/notification_payload_handler.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles push messages in the background. Runs in a separate isolate, so
/// it can't use getIt. Data-only messages with `title` and `body` are shown
/// as local notifications.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final ready = await FirebaseBootstrap.initialize();
  if (!ready) return;

  AppLogger.debug(
    'Background message: ${message.messageId}',
    name: 'PushNotificationService',
  );

  if (message.notification == null) {
    await PushNotificationService.showDataMessage(
      LocalNotificationService(),
      message,
    );
  }
}

/// Push notifications: permission, token, incoming messages and taps.
class PushNotificationService {
  PushNotificationService({
    required this._localNotifications,
    required this._payloadHandler,
    required this._tokenRegistrar,
    required this._prefs,
    FirebaseMessaging? messaging,
  }) : _messagingOverride = messaging;

  final LocalNotificationService _localNotifications;
  final NotificationPayloadHandler _payloadHandler;
  final FcmTokenRegistrar _tokenRegistrar;
  final SharedPreferencesService _prefs;
  final FirebaseMessaging? _messagingOverride;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool _initialized = false;

  // Created on first use, because it throws if Firebase isn't started.
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  bool get isAvailable => FirebaseBootstrap.isInitialized;

  String? get cachedToken => _prefs.getString(AppKeys.fcmTokenKey);

  /// Call once at startup, after Firebase and getIt are ready.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _localNotifications.initialize(
      onTap: _payloadHandler.handleRawPayload,
    );

    if (!isAvailable) {
      AppLogger.debug(
        'Firebase unavailable — push notifications disabled',
        name: 'PushNotificationService',
      );
      return;
    }

    // iOS: show notifications while the app is open.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp))
      ..add(_messaging.onTokenRefresh.listen(_onTokenRefresh));

    // The app was opened by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _onMessageOpenedApp(initialMessage);
  }

  /// Asks for notification permission. Returns true if allowed.
  Future<bool> requestPermission() async {
    try {
      if (!isAvailable) return _localNotifications.requestPermission();

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final status = settings.authorizationStatus;
      return status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Notification permission request failed',
        name: 'PushNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<String?> getToken() async {
    if (!isAvailable) return null;
    try {
      if (Platform.isIOS && await _waitForApnsToken() == null) {
        AppLogger.warning(
          'APNs token unavailable (simulator or push capability missing)',
          name: 'PushNotificationService',
        );
        return null;
      }
      final token = await _messaging.getToken();
      if (token != null) await _prefs.setString(AppKeys.fcmTokenKey, token);
      return token;
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Failed to get FCM token',
        name: 'PushNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Call after login and on startup when a session already exists.
  Future<void> syncTokenWithBackend() async {
    final token = await getToken();
    if (token != null) await _tokenRegistrar.register(token);
  }

  /// Call on logout so the next user gets a fresh token.
  Future<void> deleteToken() async {
    await _prefs.remove(AppKeys.fcmTokenKey);
    if (!isAvailable) return;
    try {
      await _messaging.deleteToken();
    } catch (e) {
      AppLogger.warning(
        'Failed to delete FCM token',
        name: 'PushNotificationService',
        error: e,
      );
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (isAvailable) await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (isAvailable) await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _initialized = false;
  }

  void _onForegroundMessage(RemoteMessage message) {
    AppLogger.debug(
      'Foreground message: ${message.messageId}',
      name: 'PushNotificationService',
    );

    final notification = message.notification;
    if (notification == null) {
      unawaited(showDataMessage(_localNotifications, message));
      return;
    }

    // Android doesn't show push notifications while the app is open, so show
    // a local one. iOS shows them by itself.
    if (Platform.isAndroid) {
      unawaited(
        _localNotifications.show(
          id: _notificationId(message),
          title: notification.title,
          body: notification.body,
          data: message.data,
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _payloadHandler.handle(message.data);
  }

  Future<void> _onTokenRefresh(String token) async {
    await _prefs.setString(AppKeys.fcmTokenKey, token);
    await _tokenRegistrar.register(token);
  }

  /// On iOS the APNs token can arrive late, and getToken fails without it.
  Future<String?> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) return apnsToken;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  static Future<void> showDataMessage(
    LocalNotificationService localNotifications,
    RemoteMessage message,
  ) async {
    final title = message.data['title'] as String?;
    final body = message.data['body'] as String?;
    if (title == null && body == null) return;

    await localNotifications.show(
      id: _notificationId(message),
      title: title,
      body: body,
      data: message.data,
    );
  }

  static int _notificationId(RemoteMessage message) =>
      (message.messageId ?? DateTime.now().toIso8601String()).hashCode &
      0x7fffffff;
}
