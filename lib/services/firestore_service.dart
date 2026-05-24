import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/suggestion_model.dart';
import '../models/comment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== SUGGESTIONS ==========

  Stream<List<SuggestionModel>> getSuggestions() {
    return _firestore
        .collection('suggestions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SuggestionModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<SuggestionModel?> getSuggestion(String id) {
    return _firestore.collection('suggestions').doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return SuggestionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> addSuggestion(SuggestionModel suggestion) async {
    await _firestore.collection('suggestions').doc(suggestion.id).set(suggestion.toMap());
  }

  Future<void> voteSuggestion(String suggestionId, String userId) async {
    final docRef = _firestore.collection('suggestions').doc(suggestionId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final userVotes = List<String>.from(data['userVotes'] ?? []);

        if (userVotes.contains(userId)) {
          userVotes.remove(userId);
          transaction.update(docRef, {
            'votes': FieldValue.increment(-1),
            'userVotes': userVotes,
          });
        } else {
          userVotes.add(userId);
          transaction.update(docRef, {
            'votes': FieldValue.increment(1),
            'userVotes': userVotes,
          });
        }
      }
    });
  }

  Future<void> updateSuggestionStatus(String id, String status) async {
    await _firestore.collection('suggestions').doc(id).update({
      'status': status,
    });
  }

  Future<void> deleteSuggestion(String id) async {
    await _firestore.collection('suggestions').doc(id).delete();
  }

  // ========== COMMENTS ==========

  Stream<List<CommentModel>> getComments(String suggestionId) {
    return _firestore
        .collection('comments')
        .where('suggestionId', isEqualTo: suggestionId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addComment(CommentModel comment) async {
    await _firestore.collection('comments').doc(comment.id).set(comment.toMap());
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  Future<void> adminRespondToComment(String commentId, String response) async {
    await _firestore.collection('comments').doc(commentId).update({
      'adminResponse': response,
      'adminResponseAt': Timestamp.now(),
    });
  }

  // ========== USERS ==========

  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  Future<DocumentSnapshot> getUser(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': isActive,
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role,
    });
  }

  Future<void> updateUserProfile(String userId, String name, String? photoUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  // ========== ADMIN RESPONSES TO SUGGESTIONS ==========

  Future<void> adminRespondToSuggestion(String suggestionId, String response) async {
    await _firestore.collection('suggestions').doc(suggestionId).update({
      'adminResponse': response,
      'adminResponseAt': Timestamp.now(),
      'status': 'in_progress',
    });
  }

  // ========== NOTIFICATIONS ==========

  Future<void> addNotification(String userId, String title, String body) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'read': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Adicione este método no FirestoreService
  Stream<QuerySnapshot> getAdminInteractions() {
    return _firestore
        .collection('suggestions')
        .where('adminResponse', isNotEqualTo: null)
        .orderBy('adminResponseAt', descending: true)
        .snapshots();
  }

// Adicione também para buscar todas as interações
  Stream<QuerySnapshot> getAllInteractions() {
    return _firestore
        .collection('suggestions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}