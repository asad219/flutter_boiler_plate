import 'package:equatable/equatable.dart';

/// Domain-level error returned inside a [Result]. [message] is always
/// safe to show in the UI (sanitized by [ApiException]).
sealed class Failure extends Equatable {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Please check your internet connection and try again.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local data.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'Something went wrong. Please try again.',
  ]);
}
