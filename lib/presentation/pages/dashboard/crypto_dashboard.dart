import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/cards/chart_card.dart';

class CryptoDashboard extends StatefulWidget {
  const CryptoDashboard({super.key});

  @override
  State<CryptoDashboard> createState() => _CryptoDashboardState();
}

class _CryptoDashboardState extends State<CryptoDashboard>
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

                    // Top Cryptocurrencies
                    _buildTopCryptos(themeProvider),
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
              'Crypto Dashboard',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track cryptocurrency prices and portfolio performance',
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
              'Add Asset',
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
        'title': 'Portfolio Value',
        'value': '\$124,567',
        'change': '+8.5%',
        'isPositive': true,
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': '24h Change',
        'value': '+2,847',
        'change': '+2.3%',
        'isPositive': true,
        'icon': Icons.trending_up_rounded,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Total Assets',
        'value': '12',
        'change': '+1',
        'isPositive': true,
        'icon': Icons.currency_bitcoin_rounded,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Market Cap',
        'value': '\$2.1T',
        'change': '+1.2%',
        'isPositive': true,
        'icon': Icons.analytics_rounded,
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
        // Bitcoin Price Chart
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Bitcoin Price',
            subtitle: 'BTC/USD - Last 7 days',
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
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          return Text(
                            days[value.toInt()],
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
                            '\$${(value * 5 + 40).toInt()}K',
                            style: style,
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 2.8),
                        const FlSpot(1, 2.9),
                        const FlSpot(2, 3.2),
                        const FlSpot(3, 3.1),
                        const FlSpot(4, 3.4),
                        const FlSpot(5, 3.6),
                        const FlSpot(6, 3.5),
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

        // Portfolio Distribution
        Expanded(
          child: ChartCard(
            title: 'Portfolio Distribution',
            subtitle: 'Asset allocation',
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

  Widget _buildTopCryptos(ThemeProvider themeProvider) {
    final cryptos = [
      {
        'name': 'Bitcoin',
        'symbol': 'BTC',
        'price': '\$43,567.89',
        'change': '+5.2%',
        'isPositive': true,
        'marketCap': '\$856.2B',
        'volume': '\$28.5B',
        'color': AppTheme.primaryColor,
      },
      {
        'name': 'Ethereum',
        'symbol': 'ETH',
        'price': '\$2,345.67',
        'change': '+3.8%',
        'isPositive': true,
        'marketCap': '\$281.9B',
        'volume': '\$15.2B',
        'color': AppTheme.secondaryColor,
      },
      {
        'name': 'Cardano',
        'symbol': 'ADA',
        'price': '\$0.456',
        'change': '-1.2%',
        'isPositive': false,
        'marketCap': '\$16.1B',
        'volume': '\$2.8B',
        'color': AppTheme.accentColor,
      },
      {
        'name': 'Solana',
        'symbol': 'SOL',
        'price': '\$98.76',
        'change': '+7.5%',
        'isPositive': true,
        'marketCap': '\$42.3B',
        'volume': '\$8.9B',
        'color': AppTheme.warningColor,
      },
      {
        'name': 'Polkadot',
        'symbol': 'DOT',
        'price': '\$7.89',
        'change': '+2.1%',
        'isPositive': true,
        'marketCap': '\$9.8B',
        'volume': '\$1.2B',
        'color': AppTheme.successColor,
      },
    ];

    return ChartCard(
      title: 'Top Cryptocurrencies',
      subtitle: 'Market leaders and performance',
      themeProvider: themeProvider,
      child: SizedBox(
        height: 500,
        child: ListView.builder(
          itemCount: cryptos.length,
          itemBuilder: (context, index) {
            final crypto = cryptos[index];
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
                      color: crypto['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Crypto Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              crypto['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              crypto['symbol'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Market Cap: ${crypto['marketCap']}',
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

                  // Price and Change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        crypto['price'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (crypto['isPositive'] as bool)
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          crypto['change'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (crypto['isPositive'] as bool)
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
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
    );
  }
}
