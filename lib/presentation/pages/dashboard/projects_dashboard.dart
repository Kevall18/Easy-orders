import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/cards/chart_card.dart';

class ProjectsDashboard extends StatefulWidget {
  const ProjectsDashboard({super.key});

  @override
  State<ProjectsDashboard> createState() => _ProjectsDashboardState();
}

class _ProjectsDashboardState extends State<ProjectsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
            gradient: themeProvider.isDarkMode
                ? AppTheme.darkBackgroundGradient
                : AppTheme.backgroundGradient,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(themeProvider),

                    const SizedBox(height: 32),

                    // Stats Cards
                    _buildStatsCards(themeProvider),

                    const SizedBox(height: 32),

                    // Charts Row
                    _buildChartsRow(themeProvider),

                    const SizedBox(height: 32),

                    // Active Projects
                    _buildActiveProjects(themeProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Projects Dashboard',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your projects and track team progress',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: themeProvider.isDarkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'New Project',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(ThemeProvider themeProvider) {
    final statsData = [
      {
        'title': 'Active Projects',
        'value': '24',
        'change': '+3',
        'isPositive': true,
        'icon': Icons.work_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Completed',
        'value': '156',
        'change': '+12',
        'isPositive': true,
        'icon': Icons.check_circle_rounded,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Team Members',
        'value': '89',
        'change': '+5',
        'isPositive': true,
        'icon': Icons.people_rounded,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'On Time',
        'value': '92%',
        'change': '+2.5%',
        'isPositive': true,
        'icon': Icons.schedule_rounded,
        'color': AppTheme.accentColor,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.7,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final data = statsData[index];
        return StatsCard(
          title: data['title'] as String,
          value: data['value'] as String,
          change: data['change'] as String,
          isPositive: data['isPositive'] as bool,
          icon: data['icon'] as IconData,
          color: data['color'] as Color,
          themeProvider: themeProvider,
        );
      },
    );
  }

  Widget _buildChartsRow(ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Progress Chart
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Project Progress',
            subtitle: 'Completion status overview',
            themeProvider: themeProvider,
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          const titles = [
                            'Planning',
                            'Design',
                            'Development',
                            'Testing',
                            'Deploy'
                          ];
                          return Text(
                            titles[value.toInt()],
                            style: style,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(
                            '${value.toInt()}%',
                            style: style,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: 85, color: AppTheme.primaryColor, width: 20)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: 72, color: AppTheme.secondaryColor, width: 20)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                          toY: 65, color: AppTheme.accentColor, width: 20)
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                          toY: 45, color: AppTheme.warningColor, width: 20)
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(
                          toY: 92, color: AppTheme.successColor, width: 20)
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Project Status
        Expanded(
          child: ChartCard(
            title: 'Project Status',
            subtitle: 'Current project distribution',
            themeProvider: themeProvider,
            child: SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppTheme.successColor,
                      value: 45,
                      title: '45%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.primaryColor,
                      value: 30,
                      title: '30%',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.warningColor,
                      value: 15,
                      title: '15%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.errorColor,
                      value: 10,
                      title: '10%',
                      radius: 35,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveProjects(ThemeProvider themeProvider) {
    final projects = [
      {
        'name': 'E-Commerce Platform',
        'progress': 85,
        'status': 'In Progress',
        'team': '8 members',
        'deadline': 'Dec 15, 2024',
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'Mobile App Redesign',
        'progress': 72,
        'status': 'In Progress',
        'team': '5 members',
        'deadline': 'Jan 20, 2025',
        'color': AppTheme.secondaryColor,
      },
      {
        'name': 'CRM System',
        'progress': 65,
        'status': 'In Progress',
        'team': '12 members',
        'deadline': 'Feb 10, 2025',
        'color': AppTheme.accentColor,
      },
      {
        'name': 'Analytics Dashboard',
        'progress': 45,
        'status': 'On Hold',
        'team': '6 members',
        'deadline': 'Mar 5, 2025',
        'color': AppTheme.warningColor,
      },
      {
        'name': 'API Integration',
        'progress': 92,
        'status': 'Almost Done',
        'team': '4 members',
        'deadline': 'Dec 30, 2024',
        'color': AppTheme.successColor,
      },
    ];

    return ChartCard(
      title: 'Active Projects',
      subtitle: 'Current project status and progress',
      themeProvider: themeProvider,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Project Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: project['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Project Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project['name'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (project['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    project['status'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: project['color'] as Color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  project['team'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeProvider.isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Deadline
                      Text(
                        project['deadline'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          Text(
                            '${project['progress']}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: project['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (project['progress'] as int) / 100,
                        backgroundColor: themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          project['color'] as Color,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
