import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant {
  /// Main action. Use one per screen.
  primary,

  /// Outlined. For secondary actions.
  secondary,

  /// Text only. For links like "Skip" or "Forgot password?".
  text,

  /// Red. For actions that can't be undone, like delete.
  danger,
}

enum AppButtonSize {
  small(height: 36, iconSize: 16, horizontalPadding: AppSpacing.md),
  medium(height: 44, iconSize: 18, horizontalPadding: AppSpacing.lg),
  large(height: 52, iconSize: 20, horizontalPadding: AppSpacing.xl);

  const AppButtonSize({
    required this.height,
    required this.iconSize,
    required this.horizontalPadding,
  });

  final double height;
  final double iconSize;
  final double horizontalPadding;
}

/// The button for the whole app.
///
/// [isLoading] shows a spinner and ignores taps. `onPressed: null` disables it.
/// It fills the width by default; set [isExpanded] to `false` inside a `Row`
/// (or wrap it in `Expanded`).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isExpanded = true,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final onTap = isLoading ? null : onPressed;
    final style = _style(context.colors);
    final child = isLoading ? _spinner() : _content();

    return switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => FilledButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
    };
  }

  ButtonStyle _style(ColorScheme colors) {
    final minimumSize = Size(isExpanded ? double.infinity : 0, size.height);
    final padding = EdgeInsets.symmetric(horizontal: size.horizontalPadding);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton.styleFrom(
        minimumSize: minimumSize,
        padding: padding,
      ),
      AppButtonVariant.danger => FilledButton.styleFrom(
        minimumSize: minimumSize,
        padding: padding,
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
      ),
      AppButtonVariant.secondary => OutlinedButton.styleFrom(
        minimumSize: minimumSize,
        padding: padding,
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        minimumSize: minimumSize,
        padding: padding,
      ),
    };
  }

  Widget _spinner() {
    return SizedBox.square(
      dimension: size.iconSize + 2,
      child: CircularProgressIndicator(strokeWidth: 2.5, semanticsLabel: label),
    );
  }

  Widget _content() {
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (icon == null && trailingIcon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: size.iconSize),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: text),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: size.iconSize),
        ],
      ],
    );
  }
}
