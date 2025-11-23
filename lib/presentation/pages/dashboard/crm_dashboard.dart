import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/cards/chart_card.dart';

class CRMDashboard extends StatefulWidget {
  const CRMDashboard({super.key});

  @override
  State<CRMDashboard> createState() => _CRMDashboardState();
}

class _CRMDashboardState extends State<CRMDashboard>
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

                    // Kanban Board
                    _buildKanbanBoard(themeProvider),

                    const SizedBox(height: 32),

                    // Customer Insights
                    _buildCustomerInsights(themeProvider),
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
              'Customer Relationship Management',
              style: AppTheme.customTextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage leads, track deals, and nurture customer relationships',
              style: AppTheme.customTextStyle(
                color:
                    themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 16,
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
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: Text(
              'Add Lead',
              style: AppTheme.customTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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
        'title': 'Total Customers',
        'value': '2,847',
        'change': '+156',
        'isPositive': true,
        'icon': Icons.people_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Active Leads',
        'value': '234',
        'change': '+23',
        'isPositive': true,
        'icon': Icons.person_search_rounded,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Conversion Rate',
        'value': '12.5%',
        'change': '+2.1%',
        'isPositive': true,
        'icon': Icons.trending_up_rounded,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Avg Deal Size',
        'value': '\$8,456',
        'change': '+15.3%',
        'isPositive': true,
        'icon': Icons.attach_money_rounded,
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

  Widget _buildKanbanBoard(ThemeProvider themeProvider) {
    final columns = [
      {
        'title': 'New Leads',
        'count': 45,
        'color': AppTheme.primaryColor,
        'leads': [
          {'name': 'John Smith', 'company': 'TechCorp Inc.', 'value': '\$25K'},
          {
            'name': 'Sarah Johnson',
            'company': 'Innovation Labs',
            'value': '\$45K'
          },
          {
            'name': 'Mike Davis',
            'company': 'Global Solutions',
            'value': '\$75K'
          },
        ],
      },
      {
        'title': 'Contacted',
        'count': 32,
        'color': AppTheme.secondaryColor,
        'leads': [
          {'name': 'Emily Wilson', 'company': 'StartupXYZ', 'value': '\$15K'},
          {
            'name': 'David Brown',
            'company': 'Enterprise Corp',
            'value': '\$120K'
          },
          {
            'name': 'Lisa Chen',
            'company': 'Digital Dynamics',
            'value': '\$60K'
          },
        ],
      },
      {
        'title': 'Qualified',
        'count': 28,
        'color': AppTheme.accentColor,
        'leads': [
          {
            'name': 'Alex Rodriguez',
            'company': 'Future Tech',
            'value': '\$90K'
          },
          {
            'name': 'Maria Garcia',
            'company': 'Cloud Solutions',
            'value': '\$85K'
          },
        ],
      },
      {
        'title': 'Proposal',
        'count': 15,
        'color': AppTheme.warningColor,
        'leads': [
          {
            'name': 'Tom Anderson',
            'company': 'Data Systems',
            'value': '\$150K'
          },
          {
            'name': 'Jennifer Lee',
            'company': 'AI Innovations',
            'value': '\$200K'
          },
        ],
      },
      {
        'title': 'Closed Won',
        'count': 12,
        'color': AppTheme.successColor,
        'leads': [
          {
            'name': 'Robert Kim',
            'company': 'Smart Solutions',
            'value': '\$180K'
          },
          {
            'name': 'Amanda White',
            'company': 'NextGen Tech',
            'value': '\$220K'
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Pipeline',
          style: AppTheme.customTextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 600,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: columns.length,
            itemBuilder: (context, index) {
              final column = columns[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column Header
                    Container(
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
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: column['color'] as Color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              column['title'] as String,
                              style: AppTheme.customTextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (column['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${column['count']}',
                              style: AppTheme.customTextStyle(
                                color: column['color'] as Color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Leads
                    Expanded(
                      child: ListView.builder(
                        itemCount: (column['leads'] as List).length,
                        itemBuilder: (context, leadIndex) {
                          final lead = (column['leads'] as List)[leadIndex];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          (column['color'] as Color)
                                              .withValues(alpha: 0.1),
                                      child: Text(
                                        (lead['name'] as String)
                                            .split(' ')
                                            .map((e) => e[0])
                                            .join(''),
                                        style: AppTheme.customTextStyle(
                                          color: column['color'] as Color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lead['name'] as String,
                                            style: AppTheme.customTextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            lead['company'] as String,
                                            style: AppTheme.customTextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      lead['value'] as String,
                                      style: AppTheme.customTextStyle(
                                        color: AppTheme.successColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInsights(ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Segments Chart
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Customer Segments',
            subtitle: 'Distribution by customer type',
            themeProvider: themeProvider,
            child: SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppTheme.primaryColor,
                      value: 40,
                      title: '40%',
                      radius: 50,
                      titleStyle: AppTheme.customTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.secondaryColor,
                      value: 30,
                      title: '30%',
                      radius: 45,
                      titleStyle: AppTheme.customTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.accentColor,
                      value: 20,
                      title: '20%',
                      radius: 40,
                      titleStyle: AppTheme.customTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.warningColor,
                      value: 10,
                      title: '10%',
                      radius: 35,
                      titleStyle: AppTheme.customTextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Top Customers
        Expanded(
          child: ChartCard(
            title: 'Top Customers',
            subtitle: 'Highest value customers',
            themeProvider: themeProvider,
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  final customers = [
                    {
                      'name': 'Enterprise Corp',
                      'value': '\$450K',
                      'growth': '+12%'
                    },
                    {
                      'name': 'TechCorp Inc.',
                      'value': '\$320K',
                      'growth': '+8%'
                    },
                    {
                      'name': 'Global Solutions',
                      'value': '\$280K',
                      'growth': '+15%'
                    },
                    {
                      'name': 'Innovation Labs',
                      'value': '\$220K',
                      'growth': '+5%'
                    },
                    {
                      'name': 'Digital Dynamics',
                      'value': '\$180K',
                      'growth': '+18%'
                    },
                  ];
                  final customer = customers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: AppTheme.customTextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer['name'] as String,
                                style: AppTheme.customTextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                customer['value'] as String,
                                style: AppTheme.customTextStyle(
                                  color: AppTheme.successColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            customer['growth'] as String,
                            style: AppTheme.customTextStyle(
                              color: AppTheme.successColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
