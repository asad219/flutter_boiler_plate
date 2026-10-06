import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_field_label.dart';
import 'package:flutter/material.dart';

/// Dropdown for short lists (up to about 10 items). Use
/// [AppSearchableDropdown] for long lists.
///
/// Keep [value] in your state and update it in [onChanged]. `T` needs a
/// working `==` (e.g. extend `Equatable`).
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final bool isRequired;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selected = items.contains(value) ? value : null;
    final canChange = enabled && !isLoading;

    return DropdownButtonFormField<T>(
      // The key rebuilds the field when [value] changes from outside.
      key: ValueKey<T?>(selected),
      initialValue: selected,
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppRadius.md),
      onChanged: canChange ? onChanged : null,
      validator: validator ?? (isRequired ? _requiredValidator(context) : null),
      icon: isLoading
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      decoration: InputDecoration(
        label: label == null
            ? null
            : AppFieldLabel(label!, isRequired: isRequired),
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      hint: Text(isLoading ? context.l10n.loading : (hint ?? '')),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  FormFieldValidator<T> _requiredValidator(BuildContext context) =>
      (value) => value == null ? requiredMessage(context, label) : null;
}
