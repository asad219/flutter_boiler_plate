import 'dart:async';

import 'package:app_boilerplate/app/routes/app_router.dart';
import 'package:app_boilerplate/app/routes/routes_name.dart';
import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/services/analytics/analytics_service.dart';
import 'package:app_boilerplate/core/services/navigation/navigation_service.dart';
import 'package:app_boilerplate/core/services/notification/notification_payload_handler.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/theme/app_theme.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = getIt<NavigationService>();
    final analyticsObserver = getIt<AnalyticsService>().navigatorObserver;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        navigatorKey: navigationService.navigatorKey,
        scaffoldMessengerKey: navigationService.scaffoldMessengerKey,
        navigatorObservers: [
          navigationService.routeObserver,
          ?analyticsObserver,
        ],
        initialRoute: RoutesName.splash,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) =>
            _AuthNavigationListener(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Single place that reacts to session changes: routing, push token sync,
/// deferred notification deep links and analytics identity.
class _AuthNavigationListener extends StatefulWidget {
  const _AuthNavigationListener({required this.child});

  final Widget child;

  @override
  State<_AuthNavigationListener> createState() =>
      _AuthNavigationListenerState();
}

class _AuthNavigationListenerState extends State<_AuthNavigationListener> {
  final NavigationService _navigation = getIt<NavigationService>();
  final PushNotificationService _push = getIt<PushNotificationService>();
  final NotificationPayloadHandler _payloadHandler =
      getIt<NotificationPayloadHandler>();
  final AnalyticsService _analytics = getIt<AnalyticsService>();

  bool _wasAuthenticated = false;

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    switch (state) {
      case Authenticated(:final user):
        _navigation.pushNamedAndClearStack(RoutesName.home);
        _payloadHandler.markReady();
        unawaited(_push.syncTokenWithBackend());
        unawaited(_analytics.setUserId(user.id));
        _wasAuthenticated = true;
      case Unauthenticated(:final message):
        _payloadHandler.markNotReady();
        _navigation.pushNamedAndClearStack(RoutesName.login);
        if (message != null) _navigation.showSnackBar(message, isError: true);
        if (_wasAuthenticated) {
          unawaited(_push.deleteToken());
          unawaited(_analytics.setUserId(null));
        }
        _wasAuthenticated = false;
      case AuthInitial() || AuthLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _onAuthStateChanged,
      child: widget.child,
    );
  }
}
