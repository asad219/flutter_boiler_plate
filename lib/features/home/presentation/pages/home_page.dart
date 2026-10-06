import 'package:app_boilerplate/core/di/service_locator.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_boilerplate/features/home/presentation/widgets/push_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Placeholder starter feature — replace with your app's first screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: authState is AuthLoading
                ? null
                : () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Hello, ${user?.fullName ?? 'there'} 👋',
            style: theme.textTheme.headlineMedium,
          ),
          if (user != null) ...[
            const SizedBox(height: 4),
            Text(user.email, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          PushStatusCard(pushService: getIt<PushNotificationService>()),
        ],
      ),
    );
  }
}
