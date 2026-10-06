import 'package:app_boilerplate/core/constants/app_constants.dart';
import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Shown while the saved session is checked. `app.dart` opens the next
/// screen.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              size: 72,
              color: context.colors.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(AppConstants.appName, style: context.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xxl),
            const AppLoader(),
          ],
        ),
      ),
    );
  }
}
