import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Código secreto para registro de administrador
  static const String ADMIN_SECRET_CODE = 'URBAN2026'; // Pode mudar para qualquer código

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        return await getUserData(result.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    }
  }

  Future<UserModel> signUpWithEmail(
      String email,
      String password,
      String name,
      String? adminCode,
      ) async {
    try {
      // Verificar se é admin e se o código está correto
      bool isAdmin = false;
      if (adminCode != null && adminCode.isNotEmpty) {
        if (adminCode == ADMIN_SECRET_CODE) {
          isAdmin = true;
        } else {
          throw Exception('Código de administrador inválido!');
        }
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userModel = UserModel(
        id: result.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: isAdmin ? 'admin' : 'citizen',
        createdAt: DateTime.now(),
        adminCode: isAdmin ? adminCode : null,
      );

      await _firestore.collection('users').doc(result.user!.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _getAuthErrorMessage(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Método para admin responder a uma sugestão
  Future<void> adminRespondToSuggestion(String suggestionId, String response) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Não autenticado');

    final userData = await getUserData(currentUser.uid);
    if (userData?.role != 'admin') throw Exception('Apenas administradores podem responder');

    await _firestore.collection('suggestions').doc(suggestionId).update({
      'adminResponse': response,
      'adminResponseAt': Timestamp.now(),
      'status': 'in_progress',
    });
  }

  // Adicione este método no AuthService
  Future<void> adminRespondToComment(String commentId, String response) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Não autenticado');

    final userData = await getUserData(currentUser.uid);
    if (userData?.role != 'admin') throw Exception('Apenas administradores podem responder');

    await _firestore.collection('comments').doc(commentId).update({
      'adminResponse': response,
      'adminResponseAt': Timestamp.now(),
    });
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Utilizador não encontrado';
      case 'wrong-password':
        return 'Palavra-passe incorrecta';
      case 'email-already-in-use':
        return 'Email já registado';
      case 'weak-password':
        return 'Palavra-passe muito fraca (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'Email inválido';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
