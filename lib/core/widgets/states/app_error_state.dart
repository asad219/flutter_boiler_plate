import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/states/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Error message with a retry button. Pass
/// `failure.localizedMessage(context.l10n)` as [message].
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: title ?? context.l10n.errorTitle,
      message: message,
      actionLabel: onRetry == null
          ? null
          : (retryLabel ?? context.l10n.tryAgain),
      onAction: onRetry,
    );
  }
}
