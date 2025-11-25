// lib/core/controllers/calendar_order_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import 'auth_controller.dart';
import 'order_controller.dart';

enum DayStatus {
  none,        // No orders
  pending,     // Orders exist, but nothing has been dispatched (blue)
  partial,     // Some items dispatched (orange)
  complete,    // All items dispatched (green)
}

class CalendarOrderController extends GetxController {
  static CalendarOrderController get instance => Get.find();

  // Assuming OrderController is properly initialized elsewhere
  // If not, use 'OrderController _orderController = Get.put(OrderController());'
  final OrderController _orderController = Get.find<OrderController>();

  // Map of date -> list of orders for that date
  final RxMap<DateTime, List<OrderModel>> ordersByDate = <DateTime, List<OrderModel>>{}.obs;

  // Map of date -> status (for dot colors)
  final RxMap<DateTime, DayStatus> dateStatusMap = <DateTime, DayStatus>{}.obs;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<OrderModel> selectedDateOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // 1. Check if orders are empty and fetch them if needed
    // This handles the case where CalendarOrderController is initialized
    // before the OrderController has finished its initial fetch.
    if (_orderController.orders.isEmpty) {
      // Use await to ensure data is fetched before proceeding,
      // though GetX will handle reactivity via ever() regardless.
      // We don't await here as onInit should be fast, and the ever listener handles the update.
      _orderController.fetchOrders();
    }

    // 2. Listen to order changes
    // This will trigger _processOrders() whenever the orders list changes (including after the fetch).
    ever(_orderController.orders, (_) => _processOrders());

    // Initial processing (in case orders were already loaded before onInit)
    _processOrders();
  }

  // Process all orders and organize by date
  void _processOrders() {
    ordersByDate.clear();
    dateStatusMap.clear();

    for (var order in _orderController.orders) {
      // Group by creation date (using createdAt, adjust if deliveryDate is required)
      final dateKey = _normalizeDate(order.orderDate);

      if (!ordersByDate.containsKey(dateKey)) {
        ordersByDate[dateKey] = [];
      }
      ordersByDate[dateKey]!.add(order);
    }

    // Calculate status for each date
    ordersByDate.forEach((date, orders) {
      dateStatusMap[date] = _calculateDayStatus(orders);
    });

    // Update selected date orders
    _updateSelectedDateOrders();
  }

  // Calculate the status of a day based on all orders
  DayStatus _calculateDayStatus(List<OrderModel> orders) {
    if (orders.isEmpty) return DayStatus.none;

    int totalItems = 0;
    int fullyDispatchedItems = 0;
    int itemsWithPartialDispatch = 0;
    int totalItemsInOrders = 0;

    for (var order in orders) {
      for (var item in order.items) {
        totalItemsInOrders++;

        // Count items with *any* dispatch
        if (item.dispatchedPcs > 0) {
          itemsWithPartialDispatch++;
        }

        // Count items that are *fully* dispatched
        if (item.dispatchedPcs == item.pcs) {
          fullyDispatchedItems++;
        }
      }
    }

    // Day has no orders
    if (totalItemsInOrders == 0) return DayStatus.none;

    // All items are fully dispatched = green
    if (fullyDispatchedItems == totalItemsInOrders) {
      return DayStatus.complete;
    }

    // Some items are fully or partially dispatched (but not all are fully dispatched) = orange
    if (itemsWithPartialDispatch > 0) {
      return DayStatus.partial;
    }

    // Orders exist, but no items have been dispatched at all = blue
    return DayStatus.pending;
  }

  // Get orders for a specific date
  List<OrderModel> getOrdersForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return ordersByDate[normalizedDate] ?? [];
  }

  // Get status for a specific date
  DayStatus getStatusForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    return dateStatusMap[normalizedDate] ?? DayStatus.none;
  }

  // Get dot color for a date
  Color? getDotColor(DateTime date) {
    final status = getStatusForDate(date);
    switch (status) {
      case DayStatus.complete:
        return Colors.green;
      case DayStatus.partial:
        return Colors.orange;
      case DayStatus.pending: // New logic for pending orders
        return Colors.blue;
      case DayStatus.none:
        return null;
    }
  }

  // Select a date and update the orders list
  void selectDate(DateTime date) {
    selectedDate.value = _normalizeDate(date);
    _updateSelectedDateOrders();
  }

  void _updateSelectedDateOrders() {
    selectedDateOrders.value = getOrdersForDate(selectedDate.value);
  }

  // Get statistics for selected date
  int get selectedDateTotalOrders => selectedDateOrders.length;

  int get selectedDateTotalItems {
    return selectedDateOrders.fold(
      0,
          (sum, order) => sum + order.items.length,
    );
  }

  int get selectedDateTotalPieces {
    return selectedDateOrders.fold(
      0,
          (sum, order) => sum + order.totalPcs,
    );
  }

  int get selectedDateDispatchedPieces {
    return selectedDateOrders.fold(
      0,
          (sum, order) => sum + order.totalDispatchedPcs,
    );
  }

  int get selectedDateInProcessPieces {
    // Total pieces that have *some* dispatch but are not fully dispatched
    final dispatched = selectedDateDispatchedPieces;
    final total = selectedDateTotalPieces;
    final fullyDispatched = selectedDateOrders.fold<int>(
      0,
          (sum, order) => sum + order.items.where((item) => item.pcs == item.dispatchedPcs).fold(0, (s, i) => s + i.pcs),
    );

    // This is more complex than just simple subtraction, as an item can be
    // partially dispatched (In Process) or fully dispatched.
    // Let's use the definition: 'In Process' means dispatched > 0 and dispatched < total
    return selectedDateOrders.fold<int>(0, (sum, order) {
      return sum + order.items.fold<int>(0, (itemSum, item) {
        // 'In Process' is typically where some pieces are dispatched but not all.
        if (item.dispatchedPcs > 0 && item.dispatchedPcs < item.pcs) {
          return itemSum + item.pcs;
        }
        return itemSum;
      });
    });
  }

  int get selectedDatePendingPieces {
    // Total pieces - (Total fully dispatched + Total partially dispatched)
    return selectedDateTotalPieces - selectedDateDispatchedPieces;
  }

  // Helper to normalize dates (remove time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Search orders on selected date
  List<OrderModel> searchSelectedDateOrders(String query) {
    if (query.isEmpty) return selectedDateOrders;

    return selectedDateOrders.where((order) {
      final partyMatch = order.partyName.toLowerCase().contains(query.toLowerCase());
      final itemMatch = order.items.any((item) =>
      item.designNo.toLowerCase().contains(query.toLowerCase()) ||
          item.fileName.toLowerCase().contains(query.toLowerCase()) ||
          item.qualityName.toLowerCase().contains(query.toLowerCase()));

      return partyMatch || itemMatch;
    }).toList();
  }

  // Add these getters to your CalendarOrderController

// Get monthly statistics for the currently focused month
  int get monthlyTotalPieces {
    return _getMonthlyOrders().fold(
      0,
          (sum, order) => sum + order.totalPcs,
    );
  }

  int get monthlyDispatchedPieces {
    return _getMonthlyOrders().fold(
      0,
          (sum, order) => sum + order.totalDispatchedPcs,
    );
  }

  int get monthlyRemainingPieces {
    return _getMonthlyOrders().fold(
      0,
          (sum, order) => sum + order.totalRemainingPcs,
    );
  }

// Update the monthlyProgramDays getter in CalendarOrderController
  double get monthlyProgramData {
    final monthlyOrders = _getMonthlyOrders();
    if (monthlyOrders.isEmpty) return 0.0;

    // Get total remaining pieces for the month
    final remainingPieces = monthlyOrders.fold(0, (sum, order) {
      return sum + order.items.fold(
        0,
            (itemSum, item) => itemSum + item.remainingPcs,
      );
    });

    // Get program days from auth controller
    final AuthController authController = Get.find<AuthController>();
    final programDays = authController.firestoreUser.value?.programDays ?? 0;

    if (programDays <= 0) return 0.0;

    // Calculate program data (days of work left)
    return remainingPieces / programDays;
  }



// Helper method to get orders for the current focused month
  List<OrderModel> _getMonthlyOrders() {
    return _orderController.orders.where((order) {
      final orderDate = _normalizeDate(order.orderDate);
      return orderDate.year == _focusedMonth.value.year &&
          orderDate.month == _focusedMonth.value.month;
    }).toList();
  }

// Add this to your controller class
  final Rx<DateTime> _focusedMonth = DateTime.now().obs;

  DateTime get focusedMonth => _focusedMonth.value;

  void setFocusedMonth(DateTime month) {
    _focusedMonth.value = DateTime(month.year, month.month, 1);
    update();
  }
}