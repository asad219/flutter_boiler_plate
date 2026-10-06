import 'dart:async';

import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/usecase/usecase.dart';
import 'package:app_boilerplate/features/auth/domain/entities/user_entity.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-wide session state.
///
/// AuthInitial → (check) → Authenticated | Unauthenticated
/// Unauthenticated → AuthLoading → Authenticated | Unauthenticated(message)
/// Authenticated → AuthLoading → Unauthenticated (logout)
/// Authenticated → Unauthenticated(message) (session expired)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._logoutUseCase,
    required this._getCurrentUserUseCase,
    required SessionExpiredNotifier sessionExpiredNotifier,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginSubmitted>(_onAuthLoginSubmitted);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);

    _sessionExpiredSubscription = sessionExpiredNotifier.stream.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUserUseCase(const NoParams());
    final user = result.dataOrNull;
    emit(user != null ? Authenticated(user) : const Unauthenticated());
  }

  Future<void> _onAuthLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(Unauthenticated(message: failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUseCase(const NoParams());
    emit(const Unauthenticated());
  }

  void _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    if (state is Unauthenticated) return;
    emit(const Unauthenticated(message: ApiException.sessionExpiredMessage));
  }

  @override
  Future<void> close() async {
    await _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
