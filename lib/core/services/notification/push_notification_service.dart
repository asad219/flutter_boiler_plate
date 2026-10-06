import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/services/firebase/firebase_bootstrap.dart';
import 'package:app_boilerplate/core/services/notification/fcm_token_registrar.dart';
import 'package:app_boilerplate/core/services/notification/local_notification_service.dart';
import 'package:app_boilerplate/core/services/notification/notification_payload_handler.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background / terminated-state FCM handler. Runs in its own isolate, so it
/// cannot use the service locator.
///
/// Messages with a `notification` block are displayed by the OS; data-only
/// messages carrying `title`/`body` are surfaced as local notifications.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final ready = await FirebaseBootstrap.initialize();
  if (!ready) return;

  developer.log(
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

/// FCM lifecycle: permissions, token registration/refresh, and
/// foreground / background-tap / terminated-tap message handling.
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

  // Resolved lazily: FirebaseMessaging.instance throws if Firebase isn't up.
  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  bool get isAvailable => FirebaseBootstrap.isInitialized;

  String? get cachedToken => _prefs.getString(AppKeys.fcmTokenKey);

  /// Call once from `main()` after Firebase + DI are ready.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _localNotifications.initialize(
      onTap: _payloadHandler.handleRawPayload,
    );

    if (!isAvailable) {
      developer.log(
        'Firebase unavailable — push notifications disabled',
        name: 'PushNotificationService',
      );
      return;
    }

    // iOS: let the OS present notification messages while in foreground.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _subscriptions
      ..add(FirebaseMessaging.onMessage.listen(_onForegroundMessage))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp))
      ..add(_messaging.onTokenRefresh.listen(_onTokenRefresh));

    // App launched from terminated state by tapping a push notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _onMessageOpenedApp(initialMessage);
  }

  /// Shows the OS permission prompt (iOS, Android 13+). Returns true if granted.
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
      developer.log(
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
        developer.log(
          'APNs token unavailable (simulator or push capability missing)',
          name: 'PushNotificationService',
        );
        return null;
      }
      final token = await _messaging.getToken();
      if (token != null) await _prefs.setString(AppKeys.fcmTokenKey, token);
      return token;
    } catch (e, stackTrace) {
      developer.log(
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
      developer.log(
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
    developer.log(
      'Foreground message: ${message.messageId}',
      name: 'PushNotificationService',
    );

    final notification = message.notification;
    if (notification == null) {
      unawaited(showDataMessage(_localNotifications, message));
      return;
    }

    // Android doesn't display FCM notifications in the foreground; iOS does
    // (see setForegroundNotificationPresentationOptions).
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

  /// APNs token can lag behind app start on iOS; FCM getToken fails without it.
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
