import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Field label with a red `*` when [isRequired]. Used by all inputs.
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key, this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    if (!isRequired) return Text(text);
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(color: context.colors.error),
          ),
        ],
      ),
    );
  }
}

/// Default "required" message for fields that set `isRequired` without a
/// custom validator.
String requiredMessage(BuildContext context, String? label) => label == null
    ? context.l10n.validationFieldRequired
    : context.l10n.validationRequired(label);
