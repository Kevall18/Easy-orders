// lib/core/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Order Item Model
class OrderItem {
  final String? id;
  final int pcs;
  final String masterDataId;
  final String designNo;
  final String fileName;
  final int jaluNo;
  final String qualityName;
  final String itemStatus;
  final String deliveryStatus;
  final int dispatchedPcs;
  final DateTime? dispatchDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    this.id,
    required this.pcs,
    required this.masterDataId,
    required this.designNo,
    required this.fileName,
    required this.jaluNo,
    required this.qualityName,
    this.itemStatus = 'pending',
    this.deliveryStatus = 'awaiting_dispatch',
    this.dispatchedPcs = 0,
    this.dispatchDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'pcs': pcs,
      'masterDataId': masterDataId,
      'designNo': designNo,
      'fileName': fileName,
      'jaluNo': jaluNo,
      'qualityName': qualityName,
      'itemStatus': itemStatus,
      'deliveryStatus': deliveryStatus,
      'dispatchedPcs': dispatchedPcs,
      'dispatchDate': dispatchDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      pcs: map['pcs'] ?? 0,
      masterDataId: map['masterDataId'] ?? '',
      designNo: map['designNo'] ?? '',
      fileName: map['fileName'] ?? '',
      jaluNo: map['jaluNo'] ?? 0,
      qualityName: map['qualityName'] ?? '',
      itemStatus: map['itemStatus'] ?? 'pending',
      deliveryStatus: map['deliveryStatus'] ?? 'awaiting_dispatch',
      dispatchedPcs: map['dispatchedPcs'] ?? 0,
      dispatchDate: map['dispatchDate'] != null
          ? DateTime.parse(map['dispatchDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
  OrderItem copyWith({
    String? id,
    int? pcs,
    String? masterDataId,
    String? designNo,
    String? fileName,
    int? jaluNo,
    String? qualityName,
    String? itemStatus,
    String? deliveryStatus,
    int? dispatchedPcs,
    DateTime? Function()? dispatchDate, // Changed to function wrapper
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      pcs: pcs ?? this.pcs,
      masterDataId: masterDataId ?? this.masterDataId,
      designNo: designNo ?? this.designNo,
      fileName: fileName ?? this.fileName,
      jaluNo: jaluNo ?? this.jaluNo,
      qualityName: qualityName ?? this.qualityName,
      itemStatus: itemStatus ?? this.itemStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      dispatchedPcs: dispatchedPcs ?? this.dispatchedPcs,
      dispatchDate: dispatchDate != null ? dispatchDate() : this.dispatchDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get itemStatusDisplay {
    return itemStatus == 'pending' ? 'Pending' : 'Finishing';
  }

  String get deliveryStatusDisplay {
    return deliveryStatus == 'awaiting_dispatch' ? 'Awaiting Dispatch' : 'Dispatched';
  }

  int get remainingPcs => pcs - dispatchedPcs;
}

// Main Order Model (Party-based)
class OrderModel {
  final String? id;
  final String userId;
  final String partyName;
  final List<OrderItem> items;
  final String? notes;
  final DateTime orderDate; // NEW: User-selectable order date
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.partyName,
    required this.items,
    this.notes,
    required this.orderDate, // NEW
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partyName': partyName,
      'items': items.map((item) => item.toMap()).toList(),
      'notes': notes,
      'orderDate': orderDate.toIso8601String(), // NEW
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firebase document
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    // For backward compatibility: use createdAt if orderDate doesn't exist
    DateTime orderDate;
    if (map['orderDate'] != null) {
      orderDate = DateTime.parse(map['orderDate']);
    } else {
      orderDate = DateTime.parse(map['createdAt']);
    }

    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      partyName: map['partyName'] ?? '',
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ??
          [],
      notes: map['notes'],
      orderDate: orderDate, // NEW
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy with updated fields
  OrderModel copyWith({
    String? id,
    String? userId,
    String? partyName,
    List<OrderItem>? items,
    String? notes,
    DateTime? orderDate, // NEW
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partyName: partyName ?? this.partyName,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate, // NEW
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total pieces across all items
  int get totalPcs {
    return items.fold(0, (sum, item) => sum + item.pcs);
  }

  // Calculate total dispatched pieces
  int get totalDispatchedPcs {
    return items.fold(0, (sum, item) => sum + item.dispatchedPcs);
  }

  // Calculate remaining pieces
  int get totalRemainingPcs {
    return totalPcs - totalDispatchedPcs;
  }

  // Get overall order status
  String getStatus() {
    if (items.isEmpty) return 'Empty';

    final allDispatched = items.every((item) => item.deliveryStatus == 'dispatched');
    final anyFinishing = items.any((item) => item.itemStatus == 'finishing');
    final anyPending = items.any((item) => item.itemStatus == 'pending');

    if (allDispatched) return 'Dispatched';
    if (anyFinishing) return 'In Process';
    if (anyPending) return 'Pending';

    return 'Unknown';
  }

  // Count items by status
  int get pendingItemsCount {
    return items.where((item) => item.itemStatus == 'pending').length;
  }

  int get finishingItemsCount {
    return items.where((item) => item.itemStatus == 'finishing').length;
  }

  int get awaitingDispatchCount {
    return items.where((item) => item.deliveryStatus == 'awaiting_dispatch').length;
  }

  int get dispatchedItemsCount {
    return items.where((item) => item.deliveryStatus == 'dispatched').length;
  }
}