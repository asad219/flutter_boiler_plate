import 'package:app_boilerplate/core/constants/app_keys.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:app_boilerplate/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Saves the language the user picked. `null` means use the device
/// language (English if the device language isn't supported).
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._prefs) : super(_read(_prefs));

  final SharedPreferencesService _prefs;

  static Locale? _read(SharedPreferencesService prefs) {
    final code = prefs.getString(AppKeys.localeKey);
    if (code == null) return null;
    final locale = Locale(code);
    return AppLocalizations.supportedLocales.contains(locale) ? locale : null;
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == state) return;
    emit(locale);
    if (locale == null) {
      await _prefs.remove(AppKeys.localeKey);
    } else {
      await _prefs.setString(AppKeys.localeKey, locale.languageCode);
    }
  }
}
