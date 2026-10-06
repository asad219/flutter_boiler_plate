import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/widgets/widgets.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_boilerplate/features/home/presentation/widgets/push_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sample home screen. Replace it with your own.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.signOutConfirmTitle,
      message: l10n.signOutConfirmMessage,
      confirmLabel: l10n.signOut,
      isDestructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final isLoading = authState.status == AuthStatus.loading;
    final l10n = context.l10n;

    return AppScaffold(
      title: l10n.homeTitle,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l10n.signOut,
          icon: const Icon(Icons.logout),
          onPressed: isLoading ? null : () => _confirmSignOut(context),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            user == null
                ? l10n.homeGreetingGuest
                : l10n.homeGreeting(user.fullName),
            style: context.textTheme.headlineMedium,
          ),
          if (user != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(user.email, style: context.textTheme.bodyLarge),
          ],
          const SizedBox(height: AppSpacing.xl),
          PushStatusCard(pushService: getIt<PushNotificationService>()),
        ],
      ),
    );
  }
}
