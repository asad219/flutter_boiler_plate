import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for non-sensitive data.
class SharedPreferencesService {
  SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesService> create() async {
    return SharedPreferencesService(await SharedPreferences.getInstance());
  }

  // Generic save method for common primitive types.
  Future<bool> setValue(String key, Object value) {
    if (value is String) return _prefs.setString(key, value);
    if (value is bool) return _prefs.setBool(key, value);
    if (value is int) return _prefs.setInt(key, value);
    if (value is double) return _prefs.setDouble(key, value);
    if (value is List<String>) return _prefs.setStringList(key, value);

    throw UnsupportedError('Type ${value.runtimeType} is not supported.');
  }

  // Generic read with fallback value.
  T? getValue<T>(String key, {T? defaultValue}) {
    final value = _prefs.get(key);
    if (value is T) return value;
    return defaultValue;
  }

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key, {String? defaultValue}) =>
      _prefs.getString(key) ?? defaultValue;

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  double getDouble(String key, {double defaultValue = 0.0}) =>
      _prefs.getDouble(key) ?? defaultValue;

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) => _prefs.getStringList(key) ?? defaultValue;

  Future<bool> remove(String key) => _prefs.remove(key);

  bool containsKey(String key) => _prefs.containsKey(key);

  Future<bool> clear() => _prefs.clear();
}
