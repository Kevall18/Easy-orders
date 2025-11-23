// lib/core/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int programDays; // New field for production capacity
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.programDays = 0, // Default to 0 if not set
    this.createdAt,
  });

  /// Converts this UserModel instance to a JSON Map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'programDays': programDays,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Creates a UserModel from a Firestore DocumentSnapshot.
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data()!;
    return UserModel(
      uid: data['uid'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      programDays: data['programDays'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Creates a copy of this UserModel with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    int? programDays,
    Timestamp? createdAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      programDays: programDays ?? this.programDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}