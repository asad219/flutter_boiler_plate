import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Shown when a route name isn't in `AppRouter`.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return AppScaffold(
      title: context.l10n.notFoundTitle,
      body: AppEmptyState(
        icon: Icons.explore_off_outlined,
        title: context.l10n.notFoundTitle,
        message: context.l10n.notFoundMessage,
        actionLabel: canPop ? context.l10n.goBack : null,
        onAction: canPop ? () => Navigator.pop(context) : null,
      ),
    );
  }
}
