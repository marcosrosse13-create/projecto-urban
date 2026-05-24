import 'package:cloud_firestore/cloud_firestore.dart';

class SuggestionModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String userId;
  final String userName;
  final int votes;
  final String status;
  final DateTime createdAt;
  final List<String> userVotes;
  final String? adminResponse;
  final DateTime? adminResponseAt;

  SuggestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.userName,
    this.votes = 0,
    this.status = 'pending',
    required this.createdAt,
    this.userVotes = const [],
    this.adminResponse,
    this.adminResponseAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'userName': userName,
      'votes': votes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'userVotes': userVotes,
      if (adminResponse != null) 'adminResponse': adminResponse,
      if (adminResponseAt != null) 'adminResponseAt': Timestamp.fromDate(adminResponseAt!),
    };
  }

  factory SuggestionModel.fromMap(String id, Map<String, dynamic> map) {
    return SuggestionModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      votes: map['votes'] ?? 0,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userVotes: List<String>.from(map['userVotes'] ?? []),
      adminResponse: map['adminResponse'],
      adminResponseAt: (map['adminResponseAt'] as Timestamp?)?.toDate(),
    );
  }
}
