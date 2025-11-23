import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<ActivityItem> _activities = [
    ActivityItem(
      title: 'New order received',
      subtitle: 'Order #12345 from John Doe',
      time: '2 minutes ago',
      icon: Icons.shopping_cart_rounded,
      color: AppTheme.primaryColor,
      type: ActivityType.order,
    ),
    ActivityItem(
      title: 'Payment successful',
      subtitle: 'Payment of \$299.99 received',
      time: '5 minutes ago',
      icon: Icons.payment_rounded,
      color: AppTheme.successColor,
      type: ActivityType.payment,
    ),
    ActivityItem(
      title: 'New customer registered',
      subtitle: 'Sarah Johnson joined the platform',
      time: '10 minutes ago',
      icon: Icons.person_add_rounded,
      color: AppTheme.secondaryColor,
      type: ActivityType.user,
    ),
    ActivityItem(
      title: 'Product updated',
      subtitle: 'iPhone 15 Pro stock updated',
      time: '15 minutes ago',
      icon: Icons.edit_rounded,
      color: AppTheme.accentColor,
      type: ActivityType.product,
    ),
    ActivityItem(
      title: 'System notification',
      subtitle: 'Backup completed successfully',
      time: '20 minutes ago',
      icon: Icons.notifications_rounded,
      color: AppTheme.warningColor,
      type: ActivityType.system,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.05),
                      AppTheme.primaryColor.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latest transactions and updates',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            tooltip: 'More options',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Activity List
                    Flexible(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView.builder(
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final activity = _activities[index];
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    20 *
                                        (1 - _animationController.value) *
                                        (index + 1),
                                  ),
                                  child: Opacity(
                                    opacity: _animationController.value,
                                    child: _buildActivityItem(
                                        activity, themeProvider),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
      ActivityItem activity, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: activity.color.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            activity.time,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final ActivityType type;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
  });
}

enum ActivityType {
  order,
  payment,
  user,
  product,
  system,
}
