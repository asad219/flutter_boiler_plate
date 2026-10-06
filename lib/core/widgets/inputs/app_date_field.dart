import 'package:app_boilerplate/core/widgets/inputs/app_field_label.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_picker_field.dart';
import 'package:flutter/material.dart';

/// Date field that opens the date picker. Shows `yyyy-MM-dd` unless you pass
/// [format].
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.value,
    this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.format = AppDateField.formatIsoDate,
    this.enabled = true,
  });

  final ValueChanged<DateTime>? onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? value;
  final String? label;
  final String? hint;
  final bool isRequired;
  final FormFieldValidator<DateTime>? validator;
  final String Function(DateTime date) format;
  final bool enabled;

  static String formatIsoDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      key: ValueKey<DateTime?>(value),
      initialValue: value,
      validator: validator ?? (isRequired ? _requiredValidator(context) : null),
      builder: (field) => AppPickerField(
        label: label,
        hint: hint,
        isRequired: isRequired,
        errorText: field.errorText,
        enabled: enabled && onChanged != null,
        suffixIcon: Icons.calendar_today_outlined,
        valueText: field.value == null ? null : format(field.value!),
        onTap: () => _pick(context, field),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    FormFieldState<DateTime> field,
  ) async {
    final current = field.value;
    final now = DateTime.now();
    final fallback = now.isBefore(firstDate)
        ? firstDate
        : (now.isAfter(lastDate) ? lastDate : now);

    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? fallback,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    field.didChange(picked);
    onChanged?.call(picked);
  }

  FormFieldValidator<DateTime> _requiredValidator(BuildContext context) =>
      (value) => value == null ? requiredMessage(context, label) : null;
}
