import 'package:app_boilerplate/core/constants/app_colors.dart';
import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType {
  success(AppColors.success, Icons.check_circle_outline),
  error(AppColors.error, Icons.error_outline),
  warning(AppColors.warning, Icons.warning_amber_rounded),
  info(AppColors.info, Icons.info_outline);

  const AppSnackBarType(this.color, this.icon);

  final Color color;
  final IconData icon;
}

/// App snackbars. Outside widgets, use `NavigationService.showSnackBar`.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(build(message, type: type));
  }

  static SnackBar build(
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    return SnackBar(
      backgroundColor: type.color,
      content: Row(
        children: [
          Icon(type.icon, color: Colors.white),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
