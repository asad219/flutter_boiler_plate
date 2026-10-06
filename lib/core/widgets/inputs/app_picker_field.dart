import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_field_label.dart';
import 'package:flutter/material.dart';

/// Read-only field that looks like [AppTextField] and calls [onTap]. Use it
/// to build custom pickers (time, country, file).
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.onTap,
    this.valueText,
    this.label,
    this.hint,
    this.isRequired = false,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon = Icons.arrow_drop_down,
    this.isLoading = false,
    this.enabled = true,
  });

  final VoidCallback onTap;

  /// Text of the current value; `null` or empty shows the [hint].
  final String? valueText;
  final String? label;
  final String? hint;
  final bool isRequired;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData suffixIcon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEmpty = valueText == null || valueText!.isEmpty;
    final canTap = enabled && !isLoading;

    return Semantics(
      button: true,
      enabled: canTap,
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InputDecorator(
          isEmpty: isEmpty,
          decoration: InputDecoration(
            enabled: enabled,
            label: label == null
                ? null
                : AppFieldLabel(label!, isRequired: isRequired),
            hintText: isLoading ? context.l10n.loading : hint,
            errorText: errorText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(suffixIcon),
          ),
          child: Text(
            valueText ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
