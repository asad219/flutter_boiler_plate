import 'dart:async';

import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// Search box with a clear button. Not a form field.
/// Set [debounce] (e.g. 400 ms) when each change calls the API.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.debounce = Duration.zero,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController? controller;

  /// Defaults to the translated "Search".
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Duration debounce;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _ownedController;
  Timer? _debounceTimer;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ownedController?.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    if (widget.debounce == Duration.zero) {
      onChanged(value);
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () => onChanged(value));
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: _handleChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hint ?? context.l10n.search,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.l10n.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
