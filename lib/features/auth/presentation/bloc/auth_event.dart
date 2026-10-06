part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Restores a stored session on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Added by the bloc itself when the session expires.
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
