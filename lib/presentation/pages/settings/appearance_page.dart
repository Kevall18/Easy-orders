import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: AppTheme.customTextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how FlutDash looks and feels.',
            style: AppTheme.customTextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),

          // Theme Mode Card
          _SettingsCard(
            title: 'Theme Mode',
            subtitle: 'Choose between Light, Dark, or follow System',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                  title: const Text('System'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                  title: const Text('Light'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (val) => themeProvider.setThemeMode(val!),
                  title: const Text('Dark'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Density (visual only placeholder)
          _SettingsCard(
            title: 'Density',
            subtitle: 'Adjust UI density (visual placeholder)',
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Comfortable'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Compact'),
                  selected: false,
                  onSelected: (_) {},
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
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.customTextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.customTextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
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
