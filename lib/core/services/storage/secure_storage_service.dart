import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around secure storage.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? _defaultStorage;

  // `first_unlock` lets background handlers (like FCM) read tokens while
  // the device is locked.
  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  final FlutterSecureStorage _storage;

  Future<void> writeString({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) {
    return _storage.read(key: key);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  Future<void> deleteAll() {
    return _storage.deleteAll();
  }
}
