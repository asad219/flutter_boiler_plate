import 'dart:io';

import 'package:app_boilerplate/core/constants/app_constants.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

/// DNS-lookup based reachability check (no plugin required).
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({
    this.host = AppConstants.connectivityCheckHost,
    this.timeout = const Duration(seconds: 5),
  });

  final String host;
  final Duration timeout;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
