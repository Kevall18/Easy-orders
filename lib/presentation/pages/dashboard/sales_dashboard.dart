import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/cards/chart_card.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({super.key});

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard>
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

                    // Top Products
                    _buildTopProducts(themeProvider),
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
              'Sales Dashboard',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your sales performance and revenue growth',
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
            icon: const Icon(Icons.add_shopping_cart_rounded,
                color: Colors.white),
            label: const Text(
              'New Sale',
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
        'title': 'Total Sales',
        'value': '\$89,432',
        'change': '+18.2%',
        'isPositive': true,
        'icon': Icons.point_of_sale_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Orders',
        'value': '2,847',
        'change': '+12.5%',
        'isPositive': true,
        'icon': Icons.shopping_bag_rounded,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Average Order',
        'value': '\$31.45',
        'change': '+5.8%',
        'isPositive': true,
        'icon': Icons.analytics_rounded,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Return Rate',
        'value': '2.4%',
        'change': '-0.8%',
        'isPositive': true,
        'icon': Icons.assignment_return_rounded,
        'color': AppTheme.warningColor,
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
        // Sales Chart
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Sales Performance',
            subtitle: 'Daily sales over the last 30 days',
            themeProvider: themeProvider,
            child: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
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
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(
                            '${value.toInt()}',
                            style: style,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(
                            '\$${(value * 2).toInt()}K',
                            style: style,
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 2.5),
                        const FlSpot(1, 2.8),
                        const FlSpot(2, 3.2),
                        const FlSpot(3, 2.9),
                        const FlSpot(4, 3.5),
                        const FlSpot(5, 3.8),
                        const FlSpot(6, 4.2),
                        const FlSpot(7, 3.9),
                        const FlSpot(8, 4.5),
                        const FlSpot(9, 4.8),
                        const FlSpot(10, 4.2),
                        const FlSpot(11, 4.6),
                        const FlSpot(12, 4.9),
                        const FlSpot(13, 4.5),
                        const FlSpot(14, 4.8),
                        const FlSpot(15, 5.0),
                        const FlSpot(16, 4.7),
                        const FlSpot(17, 4.9),
                        const FlSpot(18, 5.2),
                        const FlSpot(19, 5.0),
                        const FlSpot(20, 5.3),
                        const FlSpot(21, 5.1),
                        const FlSpot(22, 5.4),
                        const FlSpot(23, 5.2),
                        const FlSpot(24, 5.5),
                        const FlSpot(25, 5.3),
                        const FlSpot(26, 5.6),
                        const FlSpot(27, 5.4),
                        const FlSpot(28, 5.7),
                        const FlSpot(29, 5.5),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Sales by Category
        Expanded(
          child: ChartCard(
            title: 'Sales by Category',
            subtitle: 'Revenue distribution',
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
                      value: 35,
                      title: '35%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.secondaryColor,
                      value: 25,
                      title: '25%',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.accentColor,
                      value: 20,
                      title: '20%',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppTheme.warningColor,
                      value: 20,
                      title: '20%',
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

  Widget _buildTopProducts(ThemeProvider themeProvider) {
    final products = [
      {'name': 'iPhone 15 Pro', 'sales': 234, 'revenue': '\$23,400'},
      {'name': 'MacBook Air M2', 'sales': 189, 'revenue': '\$18,900'},
      {'name': 'AirPods Pro', 'sales': 156, 'revenue': '\$15,600'},
      {'name': 'iPad Air', 'sales': 123, 'revenue': '\$12,300'},
      {'name': 'Apple Watch', 'sales': 98, 'revenue': '\$9,800'},
    ];

    return ChartCard(
      title: 'Top Selling Products',
      subtitle: 'Best performing products this month',
      themeProvider: themeProvider,
      child: SizedBox(
        height: 400,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                  // Rank
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product['sales']} units sold',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Revenue
                  Text(
                    product['revenue'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.successColor,
                    ),
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
