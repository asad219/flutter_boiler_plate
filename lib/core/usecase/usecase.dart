import 'package:app_boilerplate/core/network/result.dart';
import 'package:equatable/equatable.dart';

/// Base class for use cases.
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
