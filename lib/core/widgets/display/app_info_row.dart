import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Label and value for detail screens. Empty values show `-`. Use [stacked]
/// for long values.
class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.stacked = false,
  });

  final String label;
  final String? value;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colors.onSurfaceVariant,
      ),
    );
    final valueText = Text(
      (value == null || value!.trim().isEmpty) ? '-' : value!,
      style: context.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: stacked ? TextAlign.start : TextAlign.end,
    );

    return MergeSemantics(
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelText,
                const SizedBox(height: AppSpacing.xs),
                valueText,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: labelText),
                const SizedBox(width: AppSpacing.md),
                Expanded(flex: 3, child: valueText),
              ],
            ),
    );
  }
}
