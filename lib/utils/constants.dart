import 'package:flutter/material.dart';

class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String suggestionsCollection = 'suggestions';
  static const String commentsCollection = 'comments';

  // Suggestion Categories
  static const List<String> categories = [
    'Mobilidade',
    'Iluminação',
    'Lazer',
    'Saneamento',
  ];

  // Suggestion Status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleAdmin = 'admin';

  // Map Initial Position (Maputo)
  static const double maputoLatitude = -25.969;
  static const double maputoLongitude = 32.573;
  static const double defaultZoom = 12.0;
}

class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.green;
  static const Color warning = Colors.orange;
  static const Color error = Colors.red;
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
}

class AppStrings {
  // Auth
  static const String login = 'Entrar';
  static const String register = 'Registar';
  static const String email = 'Email';
  static const String password = 'Palavra-passe';
  static const String name = 'Nome Completo';
  static const String forgotPassword = 'Esqueceu a palavra-passe?';
  static const String noAccount = 'Não tem conta? Registar';
  static const String hasAccount = 'Já tem conta? Entrar';

  // Suggestions
  static const String newSuggestion = 'Nova Sugestão';
  static const String title = 'Título';
  static const String description = 'Descrição';
  static const String category = 'Categoria';
  static const String publish = 'Publicar';
  static const String support = 'Apoiar';
  static const String supports = 'Apoios';
  static const String comments = 'Comentários';

  // Messages
  static const String success = 'Sucesso!';
  static const String error = 'Erro';
  static const String loading = 'A carregar...';
  static const String noData = 'Nenhum dado encontrado';
}