import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';

/// Section title with an optional trailing action ("View all").
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.textTheme.titleMedium),
          ),
        ),
        if (actionLabel != null && onAction != null)
          AppButton.text(
            label: actionLabel!,
            onPressed: onAction,
            size: AppButtonSize.small,
          ),
      ],
    );
  }
}
