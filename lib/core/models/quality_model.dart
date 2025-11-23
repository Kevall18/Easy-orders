// lib/core/models/quality_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QualityModel {
  final String? id;
  final String userId;
  final String qualityName;
  final int pick;
  final String col1;
  final String col2;
  final String col3;
  final String col4;
  final DateTime createdAt;
  final DateTime updatedAt;

  QualityModel({
    this.id,
    required this.userId,
    required this.qualityName,
    required this.pick,
    required this.col1,
    required this.col2,
    required this.col3,
    required this.col4,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'qualityName': qualityName,
      'pick': pick,
      'col1': col1,
      'col2': col2,
      'col3': col3,
      'col4': col4,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firebase document
  factory QualityModel.fromMap(Map<String, dynamic> map, String id) {
    return QualityModel(
      id: id,
      userId: map['userId'] ?? '',
      qualityName: map['qualityName'] ?? '',
      pick: map['pick'] ?? 0,
      col1: map['col1'] ?? '',
      col2: map['col2'] ?? '',
      col3: map['col3'] ?? '',
      col4: map['col4'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy with updated fields
  QualityModel copyWith({
    String? id,
    String? userId,
    String? qualityName,
    int? pick,
    String? col1,
    String? col2,
    String? col3,
    String? col4,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QualityModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      qualityName: qualityName ?? this.qualityName,
      pick: pick ?? this.pick,
      col1: col1 ?? this.col1,
      col2: col2 ?? this.col2,
      col3: col3 ?? this.col3,
      col4: col4 ?? this.col4,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}