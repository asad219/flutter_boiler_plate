import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Common dialogs. Button labels are translated by default.
class AppDialog {
  AppDialog._();

  /// Returns `true` only if the user taps confirm.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel ?? dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: dialogContext.colors.error,
                  )
                : null,
            child: Text(confirmLabel ?? dialogContext.l10n.confirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Shows a message with a single dismiss button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String? buttonLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(buttonLabel ?? dialogContext.l10n.ok),
          ),
        ],
      ),
    );
  }
}
