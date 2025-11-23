import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final Box settings;

  bool email = true;
  bool push = true;
  bool sms = false;
  bool marketing = false;
  bool productUpdates = true;
  bool systemAlerts = true;

  @override
  void initState() {
    super.initState();
    settings = Hive.box('settings');
    email = settings.get('notif_email', defaultValue: true);
    push = settings.get('notif_push', defaultValue: true);
    sms = settings.get('notif_sms', defaultValue: false);
    marketing = settings.get('notif_marketing', defaultValue: false);
    productUpdates = settings.get('notif_updates', defaultValue: true);
    systemAlerts = settings.get('notif_system', defaultValue: true);
  }

  Future<void> _persist() async {
    await settings.put('notif_email', email);
    await settings.put('notif_push', push);
    await settings.put('notif_sms', sms);
    await settings.put('notif_marketing', marketing);
    await settings.put('notif_updates', productUpdates);
    await settings.put('notif_system', systemAlerts);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Control how and when you get notified.',
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          _SettingsCard(
            isDark: isDark,
            title: 'Channels',
            subtitle: 'Choose where to receive notifications',
            child: Column(
              children: [
                SwitchListTile(
                  value: email,
                  onChanged: (v) => setState(() { email = v; _persist(); }),
                  title: const Text('Email'),
                  subtitle: const Text('Receive notifications via email'),
                ),
                SwitchListTile(
                  value: push,
                  onChanged: (v) => setState(() { push = v; _persist(); }),
                  title: const Text('Push'),
                  subtitle: const Text('Receive push notifications'),
                ),
                SwitchListTile(
                  value: sms,
                  onChanged: (v) => setState(() { sms = v; _persist(); }),
                  title: const Text('SMS'),
                  subtitle: const Text('Receive SMS alerts'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SettingsCard(
            isDark: isDark,
            title: 'Types',
            subtitle: 'Select what you want to be notified about',
            child: Column(
              children: [
                CheckboxListTile(
                  value: marketing,
                  onChanged: (v) => setState(() { marketing = v ?? false; _persist(); }),
                  title: const Text('Marketing & promotions'),
                ),
                CheckboxListTile(
                  value: productUpdates,
                  onChanged: (v) => setState(() { productUpdates = v ?? false; _persist(); }),
                  title: const Text('Product updates'),
                ),
                CheckboxListTile(
                  value: systemAlerts,
                  onChanged: (v) => setState(() { systemAlerts = v ?? false; _persist(); }),
                  title: const Text('System alerts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
