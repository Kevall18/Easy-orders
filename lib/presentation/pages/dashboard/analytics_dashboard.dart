// lib/presentation/pages/dashboard/analytics_dashboard.dart
// Remove local search bar, use centralized search from SearchProvider

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/order_controller.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/order_model.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final OrderController _orderController = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _orderController.fetchOrders();
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
    return Consumer2<ThemeProvider, SearchProvider>(
      builder: (context, themeProvider, searchProvider, child) {
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
                    _buildHeader(themeProvider),
                    const SizedBox(height: 32),
                    _buildStatsCards(themeProvider),
                    const SizedBox(height: 32),
                    _buildOrdersList(themeProvider, searchProvider.searchQuery),
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Orders Dashboard',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage party orders and track production',
                    style: AppTheme.customTextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile)
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/add-order'),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(
                    'New Order',
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
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/add-order'),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  'New Order',
                  style: AppTheme.customTextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCards(ThemeProvider themeProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isCompact;
        final int crossAxisCount;
        final double horizontalPadding;
        final double cardHeight;

        const minCardWidth = 140.0;
        const spacing = 16.0;

        final requiredWidthFor4 = (minCardWidth * 4) + (spacing * 3);
        final requiredWidthFor2 = (minCardWidth * 2) + spacing;

        if (width >= requiredWidthFor4) {
          crossAxisCount = 4;
          horizontalPadding = 16;
          isCompact = false;
          final cardWidth = (width - (spacing * 3) - (horizontalPadding * 2)) / 4;
          cardHeight = (cardWidth * 0.85).clamp(130.0, 160.0);
        } else if (width >= requiredWidthFor2 && width < requiredWidthFor4) {
          crossAxisCount = 2;
          horizontalPadding = width < 600 ? 0 : 16;
          isCompact = width < 600;
          final cardWidth = (width - spacing - (horizontalPadding * 2)) / 2;
          cardHeight = (cardWidth * 0.75).clamp(110.0, 140.0);
        } else {
          crossAxisCount = 1;
          horizontalPadding = 0;
          isCompact = true;
          cardHeight = 100;
        }

        return Obx(() {
          final totalOrders = _orderController.totalOrders;
          final totalPcs = _orderController.totalPieces;
          final remainingPcs = _orderController.remainingPieces;
          final dispatchedPcs = _orderController.dispatchedPieces;

          // Get program days from auth controller
          final AuthController authController = Get.find<AuthController>();
          final programDays = authController.firestoreUser.value?.programDays ?? 0;

          // Calculate program data (days of work left)
          final programData = _orderController.calculateProgramData(programDays);
          final programDataDisplay = programDays > 0
              ? '${programData.toStringAsFixed(1)} days'
              : 'Not Set';

          final totalSpacing = spacing * (crossAxisCount - 1);
          final availableWidth = width - (horizontalPadding * 2) - totalSpacing;
          final exactCardWidth = availableWidth / crossAxisCount;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: crossAxisCount == 4
                ? Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Orders',
                    totalOrders.toString(),
                    Icons.shopping_bag_rounded,
                    AppTheme.primaryColor,
                    themeProvider,
                    isCompact,
                    exactCardWidth,
                    cardHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Pieces',
                    totalPcs.toString(),
                    Icons.inventory_2_rounded,
                    AppTheme.accentColor,
                    themeProvider,
                    isCompact,
                    exactCardWidth,
                    cardHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Program Data',
                    programDataDisplay,
                    Icons.access_time_rounded,
                    AppTheme.warningColor,
                    themeProvider,
                    isCompact,
                    exactCardWidth,
                    cardHeight,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Dispatched',
                    dispatchedPcs.toString(),
                    Icons.check_circle_rounded,
                    AppTheme.successColor,
                    themeProvider,
                    isCompact,
                    exactCardWidth,
                    cardHeight,
                  ),
                ),
              ],
            )
                : Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.shopping_bag_rounded,
                  AppTheme.primaryColor,
                  themeProvider,
                  isCompact,
                  exactCardWidth,
                  cardHeight,
                ),
                _buildStatCard(
                  'Total Pieces',
                  totalPcs.toString(),
                  Icons.inventory_2_rounded,
                  AppTheme.accentColor,
                  themeProvider,
                  isCompact,
                  exactCardWidth,
                  cardHeight,
                ),
                _buildStatCard(
                  'Program Data',
                  programDataDisplay,
                  Icons.access_time_rounded,
                  AppTheme.warningColor,
                  themeProvider,
                  isCompact,
                  exactCardWidth,
                  cardHeight,
                ),
                _buildStatCard(
                  'Dispatched',
                  dispatchedPcs.toString(),
                  Icons.check_circle_rounded,
                  AppTheme.successColor,
                  themeProvider,
                  isCompact,
                  exactCardWidth,
                  cardHeight,
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ThemeProvider themeProvider,
      bool isCompact,
      double cardWidth,
      double cardHeight,
      ) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      child: isCompact
          ? _buildCompactStatLayout(title, value, icon, color, themeProvider, cardHeight)
          : _buildDesktopStatLayout(title, value, icon, color, themeProvider, cardHeight),
    );
  }

  Widget _buildCompactStatLayout(
      String title,
      String value,
      IconData icon,
      Color color,
      ThemeProvider themeProvider,
      double cardHeight,
      ) {
    final iconSize = (cardHeight * 0.25).clamp(18.0, 24.0);
    final valueSize = (cardHeight * 0.25).clamp(18.0, 24.0);
    final titleSize = (cardHeight * 0.15).clamp(12.0, 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all((cardHeight * 0.08).clamp(6.0, 10.0)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    height: 1.0,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDesktopStatLayout(
      String title,
      String value,
      IconData icon,
      Color color,
      ThemeProvider themeProvider,
      double cardHeight,
      ) {
    final iconSize = (cardHeight * 0.2).clamp(20.0, 28.0);
    final iconPadding = (cardHeight * 0.08).clamp(10.0, 14.0);
    final valueSize = (cardHeight * 0.2).clamp(20.0, 28.0);
    final titleSize = (cardHeight * 0.11).clamp(13.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: iconSize),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  height: 1.0,
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: cardHeight * 0.03),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersList(ThemeProvider themeProvider, String searchQuery) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => _orderController.fetchOrders(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (_orderController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Apply search filter
            final filteredOrders = searchQuery.isEmpty
                ? _orderController.orders
                : _orderController.searchOrders(searchQuery);

            if (filteredOrders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        searchQuery.isEmpty ? Icons.inbox_rounded : Icons.search_off_rounded,
                        size: 64,
                        color: themeProvider.isDarkMode
                            ? Colors.white38
                            : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isEmpty ? 'No orders yet' : 'No results found',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchQuery.isEmpty
                            ? 'Create your first order to get started'
                            : 'Try a different search term',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode
                              ? Colors.white54
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final size = MediaQuery.of(context).size;
            final isMobile = size.width < 768;

            if (isMobile) {
              return ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredOrders.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildMobileOrderItem(order, themeProvider);
                },
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            'Party Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total Pieces',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Items',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Created',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredOrders.map((order) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.partyName,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${order.totalPcs} pcs',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${order.items.length} items',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(_buildStatusBadge(order, themeProvider)),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(order.createdAt),
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded,
                                    color: AppTheme.primaryColor),
                                onPressed: () =>
                                    Get.toNamed('/order-detail/${order.id!}'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMobileOrderItem(OrderModel order, ThemeProvider themeProvider) {
    return InkWell(
      onTap: () => Get.toNamed('/order-detail/${order.id!}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.partyName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.totalPcs} pcs • ${order.items.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(order, themeProvider),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderModel order, ThemeProvider themeProvider) {
    final status = order.getStatus();
    Color statusColor;

    switch (status) {
      case 'Dispatched':
        statusColor = AppTheme.successColor;
        break;
      case 'In Process':
        statusColor = AppTheme.warningColor;
        break;
      case 'Pending':
        statusColor = AppTheme.primaryColor;
        break;
      default:
        statusColor = AppTheme.accentColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}