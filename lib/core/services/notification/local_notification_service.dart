import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationTapCallback = void Function(String? payload);

/// Invoked on a background isolate when a notification action is tapped
/// without bringing the app to the foreground.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  developer.log(
    'Background notification action: ${response.actionId}',
    name: 'LocalNotificationService',
  );
}

/// Wraps [FlutterLocalNotificationsPlugin]: channel setup, display, and taps.
class LocalNotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Must match the `default_notification_channel_id` in AndroidManifest.xml.
  static const String defaultChannelId = 'default_channel';

  static const AndroidNotificationChannel defaultChannel =
      AndroidNotificationChannel(
        defaultChannelId,
        'General',
        description: 'General notifications',
        importance: Importance.high,
      );

  /// [onTap] also fires once if the app was launched by tapping a local
  /// notification while terminated.
  Future<void> initialize({NotificationTapCallback? onTap}) async {
    if (_initialized) return;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Permissions are requested explicitly via [requestPermission].
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(defaultChannel);

    _initialized = true;

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      onTap?.call(launchDetails?.notificationResponse?.payload);
    }
  }

  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> show({
    required int id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) await initialize();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: data == null || data.isEmpty ? null : jsonEncode(data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          defaultChannel.id,
          defaultChannel.name,
          channelDescription: defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
