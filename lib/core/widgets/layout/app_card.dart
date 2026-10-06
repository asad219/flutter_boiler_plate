import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:flutter/material.dart';

/// Card for grouping content. Set [onTap] to make it tappable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      color: color,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
