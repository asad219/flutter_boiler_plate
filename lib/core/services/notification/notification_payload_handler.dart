import 'dart:convert';

import 'package:app_boilerplate/app/routes/app_router.dart';
import 'package:app_boilerplate/core/services/navigation/navigation_service.dart';
import 'package:app_boilerplate/core/utils/app_logger.dart';

/// Opens a screen when a notification is tapped.
///
/// Payload: `{"route": "/home", ...}`. Other keys are passed as route
/// arguments. Taps before login wait until [markReady] is called.
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
      AppLogger.warning(
        'Ignoring non-JSON notification payload',
        name: 'NotificationPayloadHandler',
        error: e,
      );
    }
  }

  /// Call after the user is logged in.
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
