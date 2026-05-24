import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String role; // 'citizen' or 'admin'
  final DateTime createdAt;
  bool isActive;
  final String? adminCode; // Código usado para registro de admin

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.role = 'citizen',
    required this.createdAt,
    this.isActive = true,
    this.adminCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'adminCode': adminCode,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      role: map['role'] ?? 'citizen',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      adminCode: map['adminCode'],
    );
  }
}