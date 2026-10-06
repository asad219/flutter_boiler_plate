import 'package:app_boilerplate/core/error/failures.dart';
import 'package:app_boilerplate/l10n/generated/app_localizations.dart';

/// Text to show for a failure, e.g.
/// `AppErrorState(message: failure.localizedMessage(context.l10n))`.
extension FailureL10n on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    ServerFailure(:final message) => message ?? l10n.errorServer,
    UnauthorizedFailure(:final message) => message ?? l10n.errorSessionExpired,
    NetworkFailure() => l10n.errorNoConnection,
    TimeoutFailure() => l10n.errorTimeout,
    CacheFailure() || UnknownFailure() => l10n.errorUnknown,
  };
}
