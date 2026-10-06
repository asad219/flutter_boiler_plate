import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/utils/validators.dart';
import 'package:app_boilerplate/core/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';

/// Password input with a show/hide button. Uses [Validators.password] by
/// default.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;

  /// Defaults to the translated "Password".
  final String? label;
  final String? hint;
  final bool isRequired;

  /// Defaults to [Validators.password].
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextInputAction textInputAction;

  /// Use `[AutofillHints.newPassword]` on sign-up / change-password forms.
  final Iterable<String> autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppTextField(
      controller: widget.controller,
      label: widget.label ?? l10n.passwordLabel,
      hint: widget.hint,
      isRequired: widget.isRequired,
      validator:
          widget.validator ?? (value) => Validators.password(value, l10n),
      enabled: widget.enabled,
      obscureText: _obscured,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      prefixIcon: Icons.lock_outline,
      suffix: IconButton(
        tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
