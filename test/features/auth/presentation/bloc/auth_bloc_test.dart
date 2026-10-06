import 'package:app_boilerplate/core/error/exceptions.dart';
import 'package:app_boilerplate/core/error/failures.dart';
import 'package:app_boilerplate/core/network/result.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/usecase/usecase.dart';
import 'package:app_boilerplate/features/auth/domain/entities/user_entity.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockGetCurrentUserUseCase getCurrentUserUseCase;
  late SessionExpiredNotifier sessionExpiredNotifier;

  const user = UserEntity(
    id: '1',
    email: 'jane@example.com',
    firstName: 'Jane',
  );
  const loginParams = LoginParams(
    email: 'jane@example.com',
    password: 'secret1',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(loginParams);
  });

  setUp(() {
    loginUseCase = MockLoginUseCase();
    logoutUseCase = MockLogoutUseCase();
    getCurrentUserUseCase = MockGetCurrentUserUseCase();
    sessionExpiredNotifier = SessionExpiredNotifier();
  });

  tearDown(() => sessionExpiredNotifier.dispose());

  AuthBloc buildBloc() => AuthBloc(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    sessionExpiredNotifier: sessionExpiredNotifier,
  );

  test('initial state is AuthInitial', () {
    expect(buildBloc().state, const AuthInitial());
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits Authenticated when a session exists',
      setUp: () => when(
        () => getCurrentUserUseCase(any()),
      ).thenAnswer((_) async => const Success(user)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const Authenticated(user)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits Unauthenticated when there is no session',
      setUp: () => when(
        () => getCurrentUserUseCase(any()),
      ).thenAnswer((_) async => const Success(null)),
      build: buildBloc,
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const Unauthenticated()],
    );
  });

  group('AuthLoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on success',
      setUp: () => when(
        () => loginUseCase(any()),
      ).thenAnswer((_) async => const Success(user)),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(
          email: 'jane@example.com',
          password: 'secret1',
        ),
      ),
      expect: () => [const AuthLoading(), const Authenticated(user)],
      verify: (_) => verify(() => loginUseCase(loginParams)).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated(message)] on failure',
      setUp: () => when(() => loginUseCase(any())).thenAnswer(
        (_) async => const Failed(ServerFailure('Invalid credentials')),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const AuthLoginSubmitted(
          email: 'jane@example.com',
          password: 'wrong12',
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(message: 'Invalid credentials'),
      ],
    );
  });

  blocTest<AuthBloc, AuthState>(
    'AuthLogoutRequested emits [AuthLoading, Unauthenticated]',
    setUp: () => when(
      () => logoutUseCase(any()),
    ).thenAnswer((_) async => const Success(null)),
    build: buildBloc,
    seed: () => const Authenticated(user),
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [const AuthLoading(), const Unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'session expiry emits Unauthenticated with a message',
    build: buildBloc,
    seed: () => const Authenticated(user),
    act: (_) => sessionExpiredNotifier.notify(),
    expect: () => [
      const Unauthenticated(message: ApiException.sessionExpiredMessage),
    ],
  );
}
