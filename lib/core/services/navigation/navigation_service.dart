import 'package:app_boilerplate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Context-free navigation and snackbars (used by BLoC listeners,
/// notification handlers and session expiry).
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final NavigatorObserver routeObserver = _RouteTracker(this);

  String? _currentRouteName;

  /// Name of the top-most named route (null for dialogs / unnamed routes).
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

  /// Clears the stack and shows [routeName]. No-op if already on it.
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

  void showSnackBar(String message, {bool isError = false}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : null,
        ),
      );
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
