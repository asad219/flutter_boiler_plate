import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Checkbox with a label that works with [Form] validation. Set
/// [mustBeChecked] for "I accept the terms".
class AppCheckboxField extends StatelessWidget {
  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.mustBeChecked = false,
    this.requiredMessage,
    this.enabled = true,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool mustBeChecked;

  /// Defaults to the translated "Please accept to continue".
  final String? requiredMessage;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final message = requiredMessage ?? context.l10n.acceptToContinue;
    return FormField<bool>(
      key: ValueKey<bool>(value),
      initialValue: value,
      validator: mustBeChecked
          ? (checked) => checked == true ? null : message
          : null,
      builder: (field) {
        final canChange = enabled && onChanged != null;
        void toggle(bool? checked) {
          final next = checked ?? false;
          field.didChange(next);
          onChanged?.call(next);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: field.value ?? false,
              onChanged: canChange ? toggle : null,
              title: Text(label, style: context.textTheme.bodyMedium),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              isError: field.hasError,
            ),
            if (field.errorText != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
                child: Text(
                  field.errorText!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
