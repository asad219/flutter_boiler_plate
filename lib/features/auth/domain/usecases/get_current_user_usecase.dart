import 'package:app_boilerplate/core/network/result.dart';
import 'package:app_boilerplate/core/usecase/usecase.dart';
import 'package:app_boilerplate/features/auth/domain/entities/user_entity.dart';
import 'package:app_boilerplate/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserEntity?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
