// lib/core/models/master_data_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataModel {
  final String? id;
  final String userId;
  final String designNo;
  final String fileName;
  final int jaluNo; // 104, 2600, or 108
  final String qualityId; // Reference to quality document
  final String qualityName; // Backup name in case quality is deleted
  final DateTime createdAt;
  final DateTime updatedAt;

  MasterDataModel({
    this.id,
    required this.userId,
    required this.designNo,
    required this.fileName,
    required this.jaluNo,
    required this.qualityId,
    required this.qualityName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'designNo': designNo,
      'fileName': fileName,
      'jaluNo': jaluNo,
      'qualityId': qualityId,
      'qualityName': qualityName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firebase document
  factory MasterDataModel.fromMap(Map<String, dynamic> map, String id) {
    return MasterDataModel(
      id: id,
      userId: map['userId'] ?? '',
      designNo: map['designNo'] ?? '',
      fileName: map['fileName'] ?? '',
      jaluNo: map['jaluNo'] ?? 104,
      qualityId: map['qualityId'] ?? '',
      qualityName: map['qualityName'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy with updated fields
  MasterDataModel copyWith({
    String? id,
    String? userId,
    String? designNo,
    String? fileName,
    int? jaluNo,
    String? qualityId,
    String? qualityName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MasterDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      designNo: designNo ?? this.designNo,
      fileName: fileName ?? this.fileName,
      jaluNo: jaluNo ?? this.jaluNo,
      qualityId: qualityId ?? this.qualityId,
      qualityName: qualityName ?? this.qualityName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get jalu display name
  String get jaluDisplayName => 'Jalu $jaluNo';

  // Available jalu optionsval@
  static const List<int> availableJaluOptions = [104, 2600, 108];
}