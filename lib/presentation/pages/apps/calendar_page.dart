import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../../core/controllers/calendar_controller.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/sidebar_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/order_model.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  late CalendarOrderController _calendarController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateUtils.dateOnly(now);

    try {
      _calendarController = Get.find<CalendarOrderController>();
    } catch (e) {
      _calendarController = Get.put(CalendarOrderController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _calendarController.selectDate(_selectedDay);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<ThemeProvider, SidebarProvider>(
      builder: (context, themeProvider, sidebarProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final isMobile = sidebarProvider.isMobile;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: isMobile
              ? AppBar(
            backgroundColor: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Text(
              'Order Calendar',
              style: AppTheme.customTextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => themeProvider.toggleTheme(),
              ),
            ],
          )
              : null,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;

              return Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: isDesktop
                    ? _buildDesktopLayout(isDark)
                    : _buildScrollableLayout(isDark, isMobile),
              );
            },
          ),
        );
      },
    );
  }

  // Desktop layout with side-by-side cards (only for large screens)
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildCalendarCard(isDark, false),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildOrdersCard(isDark, false),
        ),
      ],
    );
  }

  // Scrollable layout for mobile and tablet
  Widget _buildScrollableLayout(bool isDark, bool isMobile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendarCard(isDark, isMobile),
          const SizedBox(height: 16),
          _buildOrdersCard(isDark, isMobile),
        ],
      ),
    );
  }

  // Simplified calendar card - always uses fixed height grid
  Widget _buildCalendarCard(bool isDark, bool isMobile) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardPadding = isMobile ? 12.0 : 16.0;

    return Card(
      elevation: 0,
      color: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isDark, isMobile),
            SizedBox(height: isMobile ? 12 : 16),
            _buildWeekdayHeader(isDark, isMobile),
            SizedBox(height: isMobile ? 8 : 12),
            _buildMonthGrid(isDark, isMobile),
            SizedBox(height: isMobile ? 12 : 16),
            _buildDateInfo(isDark, isMobile, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersCard(bool isDark, bool isMobile) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardPadding = isMobile ? 12.0 : 16.0;

    return Card(
      elevation: 0,
      color: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOrdersHeader(isDark, isMobile, textColor),
            SizedBox(height: isMobile ? 8 : 12),
            _buildSearchBar(isDark, isMobile),
            SizedBox(height: isMobile ? 12 : 16),
            _buildOrdersList(isDark, isMobile, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(bool isDark, bool isMobile, Color textColor) {
    return Obx(() {
      final orders = _searchQuery.isEmpty
          ? _calendarController.selectedDateOrders
          : _calendarController.searchSelectedDateOrders(_searchQuery);

      if (orders.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.event_busy_rounded : Icons.search_off_rounded,
                  size: isMobile ? 40 : 48,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty ? 'No orders for this date' : 'No matching orders',
                  style: AppTheme.customTextStyle(
                    color: isDark ? Colors.white60 : Colors.black45,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: orders.length,
        separatorBuilder: (_, __) => SizedBox(height: isMobile ? 10 : 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, isDark, isMobile, textColor);
        },
      );
    });
  }

  Widget _buildDateInfo(bool isDark, bool isMobile, Color textColor) {
    return Obx(() {
      final ordersCount = _calendarController.selectedDateTotalOrders;
      final itemsCount = _calendarController.selectedDateTotalItems;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: isMobile ? 14 : 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDay.year}-${_two(_selectedDay.month)}-${_two(_selectedDay.day)}',
                  style: AppTheme.customTextStyle(
                    color: textColor,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (ordersCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$ordersCount ${ordersCount == 1 ? 'order' : 'orders'} • $itemsCount ${itemsCount == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, bool isMobile) {
    final monthName = _monthName(_focusedMonth.month);
    final textStyle = AppTheme.customTextStyle(
      color: isDark ? Colors.white : Colors.black87,
      fontSize: isMobile ? 16 : 18,
      fontWeight: FontWeight.w700,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$monthName ${_focusedMonth.year}', style: textStyle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _goToToday()),
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text('Today', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              Row(
                children: [
                  _navBtn(Icons.chevron_left_rounded, () => _changeMonth(-1), isMobile),
                  const SizedBox(width: 8),
                  _navBtn(Icons.chevron_right_rounded, () => _changeMonth(1), isMobile),
                ],
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Text('$monthName ${_focusedMonth.year}', style: textStyle),
        const Spacer(),
        TextButton.icon(
          onPressed: () => setState(() => _goToToday()),
          icon: const Icon(Icons.today_rounded),
          label: const Text('Today'),
        ),
        const SizedBox(width: 8),
        _navBtn(Icons.chevron_left_rounded, () => _changeMonth(-1), isMobile),
        const SizedBox(width: 6),
        _navBtn(Icons.chevron_right_rounded, () => _changeMonth(1), isMobile),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap, bool isMobile) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 6 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Icon(icon, size: isMobile ? 18 : 20),
      ),
    );
  }

  Widget _buildWeekdayHeader(bool isDark, bool isMobile) {
    final labels = isMobile
        ? const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final color = isDark ? Colors.white70 : Colors.black54;

    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              labels[i],
              style: AppTheme.customTextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 11 : 13,
              ),
            ),
          ),
        );
      }),
    );
  }

  // Simplified month grid with fixed height
  Widget _buildMonthGrid(bool isDark, bool isMobile) {
    final firstOfMonth = _focusedMonth;
    final firstDayOffset = DateUtils.firstDayOffset(
      firstOfMonth.year,
      firstOfMonth.month,
      MaterialLocalizations.of(context),
    );
    final start = firstOfMonth.subtract(Duration(days: firstDayOffset));

    final cellMargin = isMobile ? 2.0 : 4.0;
    final cellHeight = isMobile ? 60.0 : 70.0;

    return SizedBox(
      height: cellHeight * 6,
      child: Column(
        children: List.generate(6, (row) {
          return Expanded(
            child: Row(
              children: List.generate(7, (col) {
                final index = row * 7 + col;
                final day = DateUtils.addDaysToDate(start, index);
                final isCurrentMonth = day.month == firstOfMonth.month;
                final isToday = DateUtils.isSameDay(day, DateTime.now());
                final isSelected = DateUtils.isSameDay(day, _selectedDay);

                final baseText = isCurrentMonth
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white38 : Colors.black38);

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.all(cellMargin),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDay = DateUtils.dateOnly(day);
                        });
                        _calendarController.selectDate(_selectedDay);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Obx(() {
                        final dotColor = _calendarController.getDotColor(day);
                        final ordersCount = _calendarController.getOrdersForDate(day).length;

                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.6)
                                  : (isDark ? Colors.white10 : Colors.black12),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isToday)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 6 : 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${day.day}',
                                  style: AppTheme.customTextStyle(
                                    color: baseText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 12 : 14,
                                  ),
                                ),
                              SizedBox(height: isMobile ? 4 : 6),
                              if (dotColor != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: isMobile ? 8 : 10,
                                      height: isMobile ? 8 : 10,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: dotColor.withOpacity(0.5),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (ordersCount > 1) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '$ordersCount',
                                        style: TextStyle(
                                          fontSize: isMobile ? 9 : 11,
                                          fontWeight: FontWeight.w600,
                                          color: dotColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrdersHeader(bool isDark, bool isMobile, Color textColor) {
    return Obx(() {
      final stats = _calendarController;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders & Items',
                      style: AppTheme.customTextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 15 : 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_selectedDay.year}-${_two(_selectedDay.month)}-${_two(_selectedDay.day)}',
                      style: AppTheme.customTextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: isMobile ? 11 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (stats.selectedDateTotalOrders > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats.selectedDateTotalPieces} pcs',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: isMobile ? 11 : 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (stats.selectedDateTotalOrders > 0) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip('Dispatched', '${stats.selectedDateDispatchedPieces}', Colors.green, isMobile),
                _buildStatChip('In Process', '${stats.selectedDateInProcessPieces}', Colors.orange, isMobile),
                _buildStatChip('Pending', '${stats.selectedDatePendingPieces}', Colors.blue, isMobile),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildStatChip(String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, bool isMobile) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: isMobile ? 13 : 14,
      ),
      decoration: InputDecoration(
        hintText: 'Search party or item...',
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: isMobile ? 13 : 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? Colors.white60 : Colors.black54,
          size: isMobile ? 20 : 22,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
          icon: Icon(
            Icons.clear_rounded,
            color: isDark ? Colors.white60 : Colors.black54,
            size: isMobile ? 20 : 22,
          ),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
        )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 10 : 12,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark, bool isMobile, Color textColor) {
    final statusColor = order.getStatus() == 'Dispatched'
        ? Colors.green
        : order.getStatus() == 'In Process'
        ? Colors.orange
        : Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    size: isMobile ? 18 : 20,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.partyName,
                        style: AppTheme.customTextStyle(
                          color: textColor,
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${order.items.length} items • ${order.totalPcs} pcs',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.getStatus(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            child: Column(
              children: order.items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == order.items.length - 1;

                return Column(
                  children: [
                    _buildItemRow(item, isDark, isMobile, textColor),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(OrderItem item, bool isDark, bool isMobile, Color textColor) {
    final itemStatusColor = item.deliveryStatus == 'dispatched'
        ? Colors.green
        : item.itemStatus == 'finishing'
        ? Colors.orange
        : Colors.blue;

    return Row(
      children: [
        Container(
          width: isMobile ? 6 : 8,
          height: isMobile ? 6 : 8,
          decoration: BoxDecoration(
            color: itemStatusColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.designNo} - ${item.fileName}',
                style: AppTheme.customTextStyle(
                  color: textColor,
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Jalu: ${item.jaluNo} • ${item.qualityName}',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: isMobile ? 10 : 11,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.dispatchedPcs}/${item.pcs}',
              style: TextStyle(
                color: itemStatusColor,
                fontSize: isMobile ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              item.deliveryStatusDisplay,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: isMobile ? 9 : 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _changeMonth(int delta) {
    final m = DateTime(_focusedMonth.year, _focusedMonth.month + delta, 1);
    setState(() {
      _focusedMonth = m;
      final newSelectedDay = DateUtils.isSameMonth(m, _selectedDay)
          ? _selectedDay
          : DateUtils.dateOnly(DateTime(m.year, m.month, 1));
      _selectedDay = newSelectedDay;
    });
    _calendarController.selectDate(_selectedDay);
  }

  void _goToToday() {
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateUtils.dateOnly(now);
    _calendarController.selectDate(_selectedDay);
    setState(() {});
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _monthName(int m) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][m - 1];
}