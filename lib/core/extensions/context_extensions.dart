import 'package:app_boilerplate/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Short ways to read the theme: `context.colors`, `context.textTheme`.
extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// Translated strings, e.g. `context.l10n.signIn`.
extension BuildContextL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
