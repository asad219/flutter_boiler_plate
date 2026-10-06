import 'package:app_boilerplate/app/routes/not_found_page.dart';
import 'package:app_boilerplate/app/routes/routes_name.dart';
import 'package:app_boilerplate/features/auth/presentation/pages/login_page.dart';
import 'package:app_boilerplate/features/auth/presentation/pages/splash_page.dart';
import 'package:app_boilerplate/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> _routes = {
    RoutesName.splash: (_) => const SplashPage(),
    RoutesName.login: (_) => const LoginPage(),
    RoutesName.home: (_) => const HomePage(),
  };

  static bool isKnownRoute(String routeName) => _routes.containsKey(routeName);

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final builder = _routes[settings.name] ?? (_) => const NotFoundPage();
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }
}
