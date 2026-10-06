import 'package:equatable/equatable.dart';

/// Error returned inside a `Result`. Show it with
/// `failure.localizedMessage(context.l10n)`.
sealed class Failure extends Equatable {
  const Failure({this.message, this.statusCode});

  /// Message from the server, if any.
  final String? message;
  final int? statusCode;

  @override
  List<Object?> get props => [runtimeType, message, statusCode];
}

/// The server returned an error (other than 401).
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode});
}

/// 401: wrong credentials or the session expired.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message}) : super(statusCode: 401);
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// Reading or saving local data failed.
class CacheFailure extends Failure {
  const CacheFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
