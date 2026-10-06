import 'dart:async';

/// Tells the app the session expired (401 and the token can't be refreshed).
/// Fires once until [rearm] is called after the next login.
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
