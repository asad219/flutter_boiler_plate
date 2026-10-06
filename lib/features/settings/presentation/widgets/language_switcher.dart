import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/localization/locale_cubit.dart';
import 'package:app_boilerplate/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lets the user pick the app language or follow the device. The choice is
/// saved. Languages come from the `.arb` files, so a new language shows up
/// here by itself.
///
/// - `LanguageSwitcher()` for a settings page.
/// - `LanguageSwitcher.menu()` for app bar actions.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key}) : _asMenu = false;

  const LanguageSwitcher.menu({super.key}) : _asMenu = true;

  final bool _asMenu;

  static const List<Locale?> _options = [
    null,
    ...AppLocalizations.supportedLocales,
  ];

  @override
  Widget build(BuildContext context) {
    final current = context.watch<LocaleCubit>().state;
    final cubit = context.read<LocaleCubit>();
    final l10n = context.l10n;

    if (_asMenu) {
      // Use onTap: a null value would count as "menu closed".
      return PopupMenuButton<Locale?>(
        tooltip: l10n.languageLabel,
        icon: const Icon(Icons.translate),
        itemBuilder: (_) => [
          for (final option in _options)
            CheckedPopupMenuItem<Locale?>(
              checked: option == current,
              onTap: () => cubit.setLocale(option),
              child: Text(_label(l10n, option)),
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in _options)
          ListTile(
            title: Text(_label(l10n, option)),
            selected: option == current,
            trailing: option == current ? const Icon(Icons.check) : null,
            onTap: () => cubit.setLocale(option),
          ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, Locale? locale) => locale == null
      ? l10n.languageSystem
      : lookupAppLocalizations(locale).languageName;
}
