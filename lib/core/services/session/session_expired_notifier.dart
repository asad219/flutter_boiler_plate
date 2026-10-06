import 'dart:async';

/// Broadcasts session expiry (e.g. HTTP 401 with no refresh possible) so the
/// app can force re-auth.
///
/// Debounced: only one notification fires until [rearm] after a successful login.
class SessionExpiredNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();
  bool _armed = true;

  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_armed) return;
    _armed = false;
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }

  /// Call after a successful login so future 401s can notify again.
  void rearm() {
    _armed = true;
  }

  Future<void> dispose() => _controller.close();
}
