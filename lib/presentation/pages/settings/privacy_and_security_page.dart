import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyAndSecurityPage extends StatefulWidget {
  const PrivacyAndSecurityPage({super.key});

  @override
  State<PrivacyAndSecurityPage> createState() => _PrivacyAndSecurityPageState();
}

class _PrivacyAndSecurityPageState extends State<PrivacyAndSecurityPage> {
  late final Box settings;

  bool twoFA = false;
  bool biometric = false;
  bool autoLock = true;
  int sessionTimeout = 15; // minutes

  @override
  void initState() {
    super.initState();
    settings = Hive.box('settings');
    twoFA = settings.get('privacy_twoFA', defaultValue: false);
    biometric = settings.get('privacy_biometric', defaultValue: false);
    autoLock = settings.get('privacy_autoLock', defaultValue: true);
    sessionTimeout = settings.get('privacy_sessionTimeout', defaultValue: 15);
  }

  Future<void> _persist() async {
    await settings.put('privacy_twoFA', twoFA);
    await settings.put('privacy_biometric', biometric);
    await settings.put('privacy_autoLock', autoLock);
    await settings.put('privacy_sessionTimeout', sessionTimeout);
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
            'Privacy & Security',
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage authentication and session preferences.',
            style: AppTheme.customTextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          _SettingsCard(
            isDark: isDark,
            title: 'Authentication',
            subtitle: 'Secure your account with multiple protection layers',
            child: Column(
              children: [
                SwitchListTile(
                  value: twoFA,
                  onChanged: (v) => setState(() {
                    twoFA = v;
                    _persist();
                  }),
                  title: const Text('Two-Factor Authentication (2FA)'),
                  subtitle: const Text('Require a second step when logging in'),
                ),
                SwitchListTile(
                  value: biometric,
                  onChanged: (v) => setState(() {
                    biometric = v;
                    _persist();
                  }),
                  title: const Text('Biometric unlock'),
                  subtitle: const Text('Use device biometrics when available'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SettingsCard(
            isDark: isDark,
            title: 'Session',
            subtitle: 'Auto-lock and session timeout settings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  value: autoLock,
                  onChanged: (v) => setState(() {
                    autoLock = v;
                    _persist();
                  }),
                  title: const Text('Auto-lock on inactivity'),
                ),
                const SizedBox(height: 8),
                Text('Timeout: $sessionTimeout minutes'),
                Slider(
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '$sessionTimeout',
                  value: sessionTimeout.toDouble(),
                  onChanged: (val) => setState(() {
                    sessionTimeout = val.toInt();
                    _persist();
                  }),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for change password flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Change password flow coming soon')),
                    );
                  },
                  icon: const Icon(Icons.password_rounded),
                  label: const Text('Change Password'),
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
