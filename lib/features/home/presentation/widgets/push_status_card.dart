import 'package:app_boilerplate/core/services/notification/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Debug helper showing push availability and the current FCM token.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = widget.pushService.isAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Push notifications', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              available
                  ? 'Firebase is configured.'
                  : 'Firebase is not configured — see README › Firebase setup.',
              style: theme.textTheme.bodyMedium,
            ),
            if (_token != null) ...[
              const SizedBox(height: 12),
              SelectableText(
                _token!,
                maxLines: 3,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: _token!)),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy FCM token'),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loading ? null : _enableNotifications,
              child: Text(_loading ? 'Requesting…' : 'Enable notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
