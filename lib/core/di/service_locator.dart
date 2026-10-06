import 'package:app_boilerplate/core/localization/locale_cubit.dart';
import 'package:app_boilerplate/core/network/api_client.dart';
import 'package:app_boilerplate/core/network/api_interceptors.dart';
import 'package:app_boilerplate/core/services/analytics/analytics_service.dart';
import 'package:app_boilerplate/core/services/navigation/navigation_service.dart';
import 'package:app_boilerplate/core/services/notification/fcm_token_registrar.dart';
import 'package:app_boilerplate/core/services/notification/local_notification_service.dart';
import 'package:app_boilerplate/core/services/notification/notification_payload_handler.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/services/session/session_expired_notifier.dart';
import 'package:app_boilerplate/core/services/storage/secure_storage_service.dart';
import 'package:app_boilerplate/core/services/storage/secure_token_service.dart';
import 'package:app_boilerplate/core/services/storage/shared_preferences_service.dart';
import 'package:app_boilerplate/core/theme/theme_cubit.dart';
import 'package:app_boilerplate/features/auth/data/datasources/auth_local_ds.dart';
import 'package:app_boilerplate/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:app_boilerplate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_boilerplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_boilerplate/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Registers all dependencies. BLoCs are factories, everything else is a
/// lazy singleton.
Future<void> setupLocator() async {
  await _registerCore();
  _registerNetwork();
  _registerNotifications();
  _registerAuthFeature();
}

Future<void> _registerCore() async {
  final prefs = await SharedPreferencesService.create();

  getIt
    ..registerSingleton<SharedPreferencesService>(prefs)
    ..registerLazySingleton<SecureStorageService>(SecureStorageService.new)
    ..registerLazySingleton<SecureTokenService>(
      () => SecureTokenService(getIt<SecureStorageService>()),
    )
    ..registerLazySingleton<SessionExpiredNotifier>(
      SessionExpiredNotifier.new,
      dispose: (notifier) => notifier.dispose(),
    )
    ..registerLazySingleton<NavigationService>(NavigationService.new)
    ..registerLazySingleton<AnalyticsService>(AnalyticsService.new)
    ..registerFactory<ThemeCubit>(
      () => ThemeCubit(getIt<SharedPreferencesService>()),
    )
    ..registerFactory<LocaleCubit>(
      () => LocaleCubit(getIt<SharedPreferencesService>()),
    );
}

void _registerNetwork() {
  getIt
    ..registerLazySingleton<Dio>(
      () => Dio(ApiClient.defaultOptions)
        ..interceptors.addAll([
          AuthInterceptor(
            tokenService: getIt<SecureTokenService>(),
            sessionExpiredNotifier: getIt<SessionExpiredNotifier>(),
          ),
          ErrorInterceptor(),
          if (kDebugMode) LoggingInterceptor(),
        ]),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
}

void _registerNotifications() {
  getIt
    ..registerLazySingleton<LocalNotificationService>(
      LocalNotificationService.new,
    )
    ..registerLazySingleton<NotificationPayloadHandler>(
      () => NotificationPayloadHandler(getIt<NavigationService>()),
    )
    ..registerLazySingleton<FcmTokenRegistrar>(
      () => FcmTokenRegistrar(getIt<ApiClient>(), getIt<SecureTokenService>()),
    )
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(
        localNotifications: getIt<LocalNotificationService>(),
        payloadHandler: getIt<NotificationPayloadHandler>(),
        tokenRegistrar: getIt<FcmTokenRegistrar>(),
        prefs: getIt<SharedPreferencesService>(),
      ),
      dispose: (service) => service.dispose(),
    );
}

void _registerAuthFeature() {
  getIt
    // Data sources
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        tokenService: getIt<SecureTokenService>(),
        prefs: getIt<SharedPreferencesService>(),
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
        sessionExpiredNotifier: getIt<SessionExpiredNotifier>(),
      ),
    )
    // Use cases
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()),
    )
    // BLoCs
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
        sessionExpiredNotifier: getIt<SessionExpiredNotifier>(),
      ),
    );
}
