import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/theme/theme_cubit.dart';
import 'package:app_boilerplate/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lets the user pick System, Light or Dark. The choice is saved.
///
/// - `ThemeSwitcher()` for a settings page.
/// - `ThemeSwitcher.menu()` for app bar actions.
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key}) : _asMenu = false;

  const ThemeSwitcher.menu({super.key}) : _asMenu = true;

  final bool _asMenu;

  @override
  Widget build(BuildContext context) {
    final current = context.watch<ThemeCubit>().state;
    final cubit = context.read<ThemeCubit>();
    final l10n = context.l10n;

    if (_asMenu) {
      return PopupMenuButton<ThemeMode>(
        tooltip: l10n.themeLabel,
        icon: Icon(_icon(current)),
        initialValue: current,
        onSelected: cubit.setThemeMode,
        itemBuilder: (_) => [
          for (final mode in ThemeMode.values)
            CheckedPopupMenuItem<ThemeMode>(
              value: mode,
              checked: mode == current,
              child: Text(_label(l10n, mode)),
            ),
        ],
      );
    }

    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      selected: {current},
      onSelectionChanged: (selection) => cubit.setThemeMode(selection.first),
      segments: [
        for (final mode in ThemeMode.values)
          ButtonSegment<ThemeMode>(
            value: mode,
            icon: Icon(_icon(mode)),
            label: Text(_label(l10n, mode)),
          ),
      ],
    );
  }

  static IconData _icon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  static String _label(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.system => l10n.themeSystem,
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
  };
}
