import 'dart:convert';
import 'dart:developer' as developer;

import 'package:app_boilerplate/app/routes/app_router.dart';
import 'package:app_boilerplate/core/services/navigation/navigation_service.dart';

/// Turns notification payloads into navigation.
///
/// Payload contract (FCM `data` or local notification payload):
/// `{"route": "/home", ...extra}` — extra keys are passed as route arguments.
///
/// Taps that arrive before the user is authenticated (cold start, login
/// screen) are held until [markReady] so deep links never bypass auth.
class NotificationPayloadHandler {
  NotificationPayloadHandler(this._navigationService);

  final NavigationService _navigationService;

  static const String routeKey = 'route';

  bool _ready = false;
  Map<String, dynamic>? _pending;

  void handle(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (!_ready) {
      _pending = data;
      return;
    }
    _route(data);
  }

  void handleRawPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) handle(decoded);
    } catch (e) {
      developer.log(
        'Ignoring non-JSON notification payload',
        name: 'NotificationPayloadHandler',
        error: e,
      );
    }
  }

  /// Call once the authenticated shell is visible.
  void markReady() {
    _ready = true;
    final pending = _pending;
    _pending = null;
    if (pending != null) _route(pending);
  }

  void markNotReady() {
    _ready = false;
  }

  void _route(Map<String, dynamic> data) {
    final route = data[routeKey];
    if (route is! String || !AppRouter.isKnownRoute(route)) return;
    _navigationService.pushNamed<void>(route, arguments: data);
  }
}
