import 'dart:async';

import 'package:app_boilerplate/app/routes/app_router.dart';
import 'package:app_boilerplate/app/routes/routes_name.dart';
import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/constants/app_typography.dart';
import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/error/failure_l10n.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/localization/locale_cubit.dart';
import 'package:app_boilerplate/core/services/analytics/analytics_service.dart';
import 'package:app_boilerplate/core/services/crash/crash_reporter.dart';
import 'package:app_boilerplate/core/services/navigation/navigation_service.dart';
import 'package:app_boilerplate/core/services/notification/notification_payload_handler.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/theme/app_theme.dart';
import 'package:app_boilerplate/core/theme/theme_cubit.dart';
import 'package:app_boilerplate/core/widgets/widgets.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_boilerplate/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>(create: (_) => getIt<LocaleCubit>()),
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final navigationService = getIt<NavigationService>();
    final analyticsObserver = getIt<AnalyticsService>().navigatorObserver;
    final themeMode = context.watch<ThemeCubit>().state;
    final locale = context.watch<LocaleCubit>().state;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      navigatorKey: navigationService.navigatorKey,
      scaffoldMessengerKey: navigationService.scaffoldMessengerKey,
      navigatorObservers: [navigationService.routeObserver, ?analyticsObserver],
      initialRoute: RoutesName.splash,
      onGenerateRoute: AppRouter.generateRoute,
      // The final locale is only known here, so the language font is set here.
      builder: (context, child) => Theme(
        data: AppTheme.withFontFamily(
          Theme.of(context),
          AppTypography.fontFamilyFor(Localizations.localeOf(context)),
        ),
        child: _AuthNavigationListener(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Reacts to login and logout: opens the right screen, shows errors and
/// updates push, analytics and Crashlytics.
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
      case AuthState(status: AuthStatus.authenticated, :final user?):
        _navigation.pushNamedAndClearStack(RoutesName.home);
        _payloadHandler.markReady();
        unawaited(_push.syncTokenWithBackend());
        unawaited(_analytics.setUserId(user.id));
        unawaited(CrashReporter.setUserId(user.id));
        _wasAuthenticated = true;
      case AuthState(status: AuthStatus.unauthenticated, :final failure):
        _payloadHandler.markNotReady();
        _navigation.pushNamedAndClearStack(RoutesName.login);
        if (failure != null) {
          _navigation.showSnackBar(
            failure.localizedMessage(context.l10n),
            type: AppSnackBarType.error,
          );
        }
        if (_wasAuthenticated) {
          unawaited(_push.deleteToken());
          unawaited(_analytics.setUserId(null));
          unawaited(CrashReporter.setUserId(null));
        }
        _wasAuthenticated = false;
      case AuthState():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Only when the status changes, not when the user data changes.
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onAuthStateChanged,
      child: widget.child,
    );
  }
}
