import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/widgets/feedback/app_loader.dart';
import 'package:flutter/material.dart';

/// Base layout for every screen: app bar, safe area, padding, hides the
/// keyboard on tap, optional scrolling and a loading overlay.
///
/// If [body] scrolls by itself (e.g. `ListView`), keep [scrollable] false and
/// pass `padding: EdgeInsets.zero`.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.actions,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.scrollable = false,
    this.maxContentWidth,
    this.isLoading = false,
    this.loadingMessage,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  final Widget body;

  /// Builds a default [AppBar]. Ignored when [appBar] is set.
  final String? title;
  final PreferredSizeWidget? appBar;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final double? maxContentWidth;
  final bool isLoading;
  final String? loadingMessage;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = scrollable
        ? SingleChildScrollView(padding: padding, child: body)
        : Padding(padding: padding, child: body);

    if (maxContentWidth != null) {
      content = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: content,
        ),
      );
    }

    return AppLoadingOverlay(
      isLoading: isLoading,
      message: loadingMessage,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar:
            appBar ??
            (title == null
                ? null
                : AppBar(title: Text(title!), actions: actions)),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(child: content),
        ),
      ),
    );
  }
}
