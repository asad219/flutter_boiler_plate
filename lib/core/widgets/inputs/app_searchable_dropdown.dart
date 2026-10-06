import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_field_label.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_picker_field.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_search_field.dart';
import 'package:app_boilerplate/core/widgets/states/app_empty_state.dart';
import 'package:flutter/material.dart';

/// Dropdown for long lists (countries, cities). Opens a bottom sheet with a
/// search box. Works like [AppDropdown].
class AppSearchableDropdown<T> extends StatelessWidget {
  const AppSearchableDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.searchHint,
    this.isRequired = false,
    this.validator,
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T>? onChanged;
  final T? value;
  final String? label;
  final String? hint;

  /// Defaults to the translated "Search".
  final String? searchHint;
  final bool isRequired;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      // The key rebuilds the field when [value] changes from outside.
      key: ValueKey<T?>(value),
      initialValue: value,
      validator: validator ?? (isRequired ? _requiredValidator(context) : null),
      builder: (field) {
        final selected = field.value;
        return AppPickerField(
          label: label,
          hint: hint,
          isRequired: isRequired,
          prefixIcon: prefixIcon,
          errorText: field.errorText,
          isLoading: isLoading,
          enabled: enabled && onChanged != null,
          valueText: selected == null ? null : itemLabel(selected),
          onTap: () => _open(context, field),
        );
      },
    );
  }

  Future<void> _open(BuildContext context, FormFieldState<T> field) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SearchSheet<T>(
        title: label ?? hint,
        items: items,
        itemLabel: itemLabel,
        selected: field.value,
        searchHint: searchHint,
      ),
    );
    if (picked == null) return;
    field.didChange(picked);
    onChanged?.call(picked);
  }

  FormFieldValidator<T> _requiredValidator(BuildContext context) =>
      (value) => value == null ? requiredMessage(context, label) : null;
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selected,
    required this.searchHint,
  });

  final String? title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final String? searchHint;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  String _query = '';

  List<T> get _filtered {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items
        .where((item) => widget.itemLabel(item).toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return FractionallySizedBox(
      heightFactor: 0.75,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppSearchField(
              hint: widget.searchHint,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: filtered.isEmpty
                  ? AppEmptyState(
                      icon: Icons.search_off,
                      title: _query.isEmpty
                          ? context.l10n.noOptions
                          : context.l10n.noResultsFor(_query),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = item == widget.selected;
                        return ListTile(
                          title: Text(widget.itemLabel(item)),
                          selected: isSelected,
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
