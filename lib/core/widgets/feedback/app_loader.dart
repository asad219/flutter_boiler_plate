import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Centered spinner with an optional message, for loading pages.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message, this.size = 32});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              semanticsLabel: message ?? context.l10n.loading,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows a loader over [child] and blocks taps while [isLoading]. Use it
/// while submitting a form or uploading.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(
              color: context.colors.scrim.withValues(alpha: 0.3),
              child: AbsorbPointer(
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: AppLoader(message: message),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
