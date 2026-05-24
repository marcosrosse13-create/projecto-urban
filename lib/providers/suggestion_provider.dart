import 'package:flutter/material.dart';
import '../models/suggestion_model.dart';
import '../services/firestore_service.dart';

class SuggestionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SuggestionModel> _suggestions = [];
  bool _isLoading = true;

  List<SuggestionModel> get suggestions => _suggestions;
  bool get isLoading => _isLoading;

  SuggestionProvider() {
    _listenToSuggestions();
  }

  void _listenToSuggestions() {
    _firestoreService.getSuggestions().listen((suggestions) {
      _suggestions = suggestions;
      _isLoading = false;
      notifyListeners();
    });
  }

  // New method to get stream for map
  Stream<List<SuggestionModel>> getSuggestionsStream() {
    return _firestoreService.getSuggestions();
  }

  Future<void> addSuggestion(SuggestionModel suggestion) async {
    await _firestoreService.addSuggestion(suggestion);
  }

  Future<void> voteSuggestion(String suggestionId, String userId) async {
    await _firestoreService.voteSuggestion(suggestionId, userId);
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestoreService.updateSuggestionStatus(id, status);
  }

  Future<void> deleteSuggestion(String id) async {
    await _firestoreService.deleteSuggestion(id);
  }

  List<SuggestionModel> getSuggestionsByCategory(String category) {
    if (category == 'Todas') {
      return _suggestions;
    }
    return _suggestions.where((s) => s.category == category).toList();
  }

  SuggestionModel? getSuggestionById(String id) {
    try {
      return _suggestions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}