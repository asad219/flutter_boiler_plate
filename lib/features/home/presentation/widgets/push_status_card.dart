import 'package:app_boilerplate/core/constants/app_dimens.dart';
import 'package:app_boilerplate/core/extensions/context_extensions.dart';
import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:app_boilerplate/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows if push works and lets you copy the FCM token. For testing.
class PushStatusCard extends StatefulWidget {
  const PushStatusCard({super.key, required this.pushService});

  final PushNotificationService pushService;

  @override
  State<PushStatusCard> createState() => _PushStatusCardState();
}

class _PushStatusCardState extends State<PushStatusCard> {
  String? _token;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _token = widget.pushService.cachedToken;
  }

  Future<void> _enableNotifications() async {
    setState(() => _loading = true);
    await widget.pushService.requestPermission();
    final token = await widget.pushService.getToken();
    if (!mounted) return;
    setState(() {
      _token = token;
      _loading = false;
    });
  }

  Future<void> _copyToken() async {
    await Clipboard.setData(ClipboardData(text: _token!));
    if (!mounted) return;
    AppSnackBar.show(
      context,
      context.l10n.pushTokenCopied,
      type: AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = context.l10n;
    final available = widget.pushService.isAvailable;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.pushTitle, style: textTheme.titleMedium),
              ),
              AppBadge(
                label: available ? l10n.pushConfigured : l10n.pushNotConfigured,
                tone: available ? AppBadgeTone.success : AppBadgeTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            available
                ? l10n.pushConfiguredMessage
                : l10n.pushNotConfiguredMessage,
            style: textTheme.bodyMedium,
          ),
          if (_token != null) ...[
            const SizedBox(height: AppSpacing.md),
            SelectableText(
              _token!,
              maxLines: 3,
              style: textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            ),
            AppButton.text(
              label: l10n.pushCopyToken,
              icon: Icons.copy,
              onPressed: _copyToken,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: l10n.pushEnable,
            isLoading: _loading,
            onPressed: _enableNotifications,
          ),
        ],
      ),
    );
  }
}
