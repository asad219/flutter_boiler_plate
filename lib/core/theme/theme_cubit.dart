import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Saves the theme mode the user picked. The default is system.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_read(_prefs));

  final SharedPreferencesService _prefs;

  static ThemeMode _read(SharedPreferencesService prefs) {
    final stored = prefs.getString(AppKeys.themeModeKey);
    return ThemeMode.values.asNameMap()[stored] ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _prefs.setString(AppKeys.themeModeKey, mode.name);
  }
}
