part of 'auth_bloc.dart';

enum AuthStatus {
  /// Checking for a saved session (splash screen).
  initial,

  /// Login / logout in progress.
  loading,
  authenticated,
  unauthenticated,
}

final class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.user, this.failure});

  final AuthStatus status;

  /// Kept during logout so the screen doesn't flicker.
  final UserEntity? user;

  /// Why the user was signed out (failed login, expired session).
  final Failure? failure;

  /// `failure` is reset on every copy unless you pass it again.
  /// Use `clearUser: true` to remove the user.
  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool clearUser = false,
    Failure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, user, failure];
}
