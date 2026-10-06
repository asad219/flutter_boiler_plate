import 'package:app_boilerplate/core/widgets/feedback/app_snack_bar.dart';
import 'package:flutter/material.dart';

/// Navigation and snackbars without a BuildContext.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final NavigatorObserver routeObserver = _RouteTracker(this);

  String? _currentRouteName;

  /// Name of the top route (null for dialogs and unnamed routes).
  String? get currentRouteName => _currentRouteName;

  BuildContext? get currentContext => navigatorKey.currentContext;

  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushReplacementNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushReplacementNamed<T, Object?>(
      routeName,
      arguments: arguments,
    );
  }

  /// Clears the stack and opens [routeName]. Does nothing if already there.
  void pushNamedAndClearStack(String routeName, {Object? arguments}) {
    if (_currentRouteName == routeName) return;
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  void showSnackBar(
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(AppSnackBar.build(message, type: type));
  }
}

class _RouteTracker extends NavigatorObserver {
  _RouteTracker(this._service);

  final NavigationService _service;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _service._currentRouteName = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _service._currentRouteName = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute?.settings.name == _service._currentRouteName) {
      _service._currentRouteName = newRoute?.settings.name;
    }
  }
}
