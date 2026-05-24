import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String suggestionId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final String? adminResponse; // Resposta do admin ao comentário
  final DateTime? adminResponseAt;

  CommentModel({
    required this.id,
    required this.suggestionId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.adminResponse,
    this.adminResponseAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'suggestionId': suggestionId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      if (adminResponse != null) 'adminResponse': adminResponse,
      if (adminResponseAt != null) 'adminResponseAt': Timestamp.fromDate(adminResponseAt!),
    };
  }

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      suggestionId: map['suggestionId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminResponse: map['adminResponse'],
      adminResponseAt: (map['adminResponseAt'] as Timestamp?)?.toDate(),
    );
  }
}