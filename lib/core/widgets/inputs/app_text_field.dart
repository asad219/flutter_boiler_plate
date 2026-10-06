import 'package:app_boilerplate/core/widgets/inputs/app_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text input for forms. The look comes from the theme.
///
/// - [isRequired] adds a `*` and, if there's no [validator], checks the field
///   isn't empty.
/// - Pass [controller] or [initialValue], not both.
/// - Set `maxLines` above 1 for multiline.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.helperText,
    this.isRequired = false,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.autovalidateMode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  }) : assert(
         controller == null || initialValue == null,
         'Pass either controller or initialValue, not both.',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final String? helperText;
  final bool isRequired;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines != 1;

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      keyboardType:
          keyboardType ?? (isMultiline ? TextInputType.multiline : null),
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autofillHints: enabled ? autofillHints : null,
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator ?? (isRequired ? _requiredValidator(context) : null),
      decoration: InputDecoration(
        label: label == null
            ? null
            : AppFieldLabel(label!, isRequired: isRequired),
        hintText: hint,
        helperText: helperText,
        alignLabelWithHint: isMultiline,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffix,
      ),
    );
  }

  FormFieldValidator<String> _requiredValidator(BuildContext context) =>
      (value) => (value == null || value.trim().isEmpty)
      ? requiredMessage(context, label)
      : null;
}
