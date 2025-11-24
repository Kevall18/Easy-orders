// lib/core/controllers/order_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // Fetch all orders for current user
  Future<void> fetchOrders() async {
    try {
      if (_authController.user == null) return;

      isLoading.value = true;
      errorMessage.value = '';

      final QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _authController.user!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      orders.value = snapshot.docs
          .map((doc) => OrderModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      ))
          .toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to fetch orders: ${e.toString()}';
      print('Error fetching orders: $e');
    }
  }

  // Create new order
  Future<bool> createOrder(OrderModel order) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final docRef = await _firestore.collection('orders').add(order.toMap());

      // Add to local list
      orders.insert(
        0,
        order.copyWith(id: docRef.id),
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to create order: ${e.toString()}';
      print('Error creating order: $e');
      return false;
    }
  }

  // Update existing order
  Future<bool> updateOrder(OrderModel order) async {
    try {
      if (order.id == null) return false;

      isLoading.value = true;
      errorMessage.value = '';

      final updatedOrder = order.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('orders')
          .doc(order.id)
          .update(updatedOrder.toMap());

      // Update local list
      final index = orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        orders[index] = updatedOrder;
      }

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to update order: ${e.toString()}';
      print('Error updating order: $e');
      return false;
    }
  }

  // Delete order
  Future<bool> deleteOrder(String orderId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _firestore.collection('orders').doc(orderId).delete();

      // Remove from local list
      orders.removeWhere((o) => o.id == orderId);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to delete order: ${e.toString()}';
      print('Error deleting order: $e');
      return false;
    }
  }

  // Update item status (pending/finishing)
  Future<bool> updateItemStatus(String orderId, int itemIndex, String newStatus) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      final items = List<OrderItem>.from(order.items);

      items[itemIndex] = items[itemIndex].copyWith(
        itemStatus: newStatus,
        updatedAt: DateTime.now(),
      );

      return await updateOrder(order.copyWith(items: items));
    } catch (e) {
      errorMessage.value = 'Failed to update item status: ${e.toString()}';
      return false;
    }
  }

  // Update delivery status and dispatch pieces
  Future<bool> dispatchItem(
      String orderId,
      int itemIndex,
      int dispatchedPcs,
      ) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      final items = List<OrderItem>.from(order.items);
      final item = items[itemIndex];

      // Validate dispatched pieces
      if (dispatchedPcs > item.remainingPcs) {
        errorMessage.value = 'Cannot dispatch more pieces than remaining';
        return false;
      }

      items[itemIndex] = item.copyWith(
        deliveryStatus: 'dispatched',
        dispatchedPcs: item.dispatchedPcs + dispatchedPcs,
        dispatchDate: () => DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await updateOrder(order.copyWith(items: items));
    } catch (e) {
      errorMessage.value = 'Failed to dispatch item: ${e.toString()}';
      return false;
    }
  }

  // Delete a single item from order
  Future<bool> deleteOrderItem(String orderId, int itemIndex) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      final items = List<OrderItem>.from(order.items);

      items.removeAt(itemIndex);

      // If no items left, delete the entire order
      if (items.isEmpty) {
        return await deleteOrder(orderId);
      }

      return await updateOrder(order.copyWith(items: items));
    } catch (e) {
      errorMessage.value = 'Failed to delete item: ${e.toString()}';
      return false;
    }
  }

  // Add new item to existing order
  Future<bool> addItemToOrder(String orderId, OrderItem newItem) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      final items = List<OrderItem>.from(order.items);

      items.add(newItem);

      return await updateOrder(order.copyWith(items: items));
    } catch (e) {
      errorMessage.value = 'Failed to add item: ${e.toString()}';
      return false;
    }
  }

  // Update an order item (change master data, pcs, etc.)
  Future<bool> updateOrderItem(
      String orderId,
      int itemIndex,
      OrderItem updatedItem,
      ) async {
    try {
      final order = orders.firstWhere((o) => o.id == orderId);
      final items = List<OrderItem>.from(order.items);

      items[itemIndex] = updatedItem.copyWith(updatedAt: DateTime.now());

      return await updateOrder(order.copyWith(items: items));
    } catch (e) {
      errorMessage.value = 'Failed to update item: ${e.toString()}';
      return false;
    }
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return orders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Search orders by party name
  List<OrderModel> searchOrders(String query) {
    if (query.isEmpty) return orders;

    return orders.where((order) {
      return order.partyName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get statistics
  int get totalOrders => orders.length;

  int get totalPieces {
    return orders.fold(0, (sum, order) => sum + order.totalPcs);
  }

  int get pendingPieces {
    return orders.fold(0, (sum, order) {
      return sum + order.items.fold(
        0,
            (itemSum, item) => itemSum + (item.pcs - item.dispatchedPcs),
      );
    });
  }


  int get finishingPieces {
    return orders.fold(0, (sum, order) {
      return sum +
          order.items
              .where((item) => item.itemStatus == 'finishing')
              .fold(0, (itemSum, item) => itemSum + item.pcs);
    });
  }

  int get dispatchedPieces {
    return orders.fold(0, (sum, order) => sum + order.totalDispatchedPcs);
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }
// Get remaining pieces regardless of status
  int get remainingPieces {
    return orders.fold(0, (sum, order) {
      return sum + order.items.fold(
        0,
            (itemSum, item) => itemSum + item.remainingPcs,
      );
    });
  }


// Calculate program data (days of work remaining)
  double calculateProgramData(int programDays) {
    if (programDays <= 0) return 0.0;

    final remaining = remainingPieces;
    return remaining / programDays;
  }
}