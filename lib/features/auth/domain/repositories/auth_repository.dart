import 'package:app_boilerplate/core/network/result.dart';
import 'package:app_boilerplate/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  /// Always clears the local session, even if the server call fails.
  Future<Result<void>> logout();

  /// `Success(null)` means there is no stored session.
  Future<Result<UserEntity?>> getCurrentUser();
}
