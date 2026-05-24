import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/suggestion_model.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class AdminResponseScreen extends StatefulWidget {
  final SuggestionModel suggestion;

  const AdminResponseScreen({super.key, required this.suggestion});

  @override
  State<AdminResponseScreen> createState() => _AdminResponseScreenState();
}

class _AdminResponseScreenState extends State<AdminResponseScreen> {
  final TextEditingController _responseController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder à Sugestão'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.suggestion.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.suggestion.description),
                    const SizedBox(height: 8),
                    Text(
                      'Autor: ${widget.suggestion.userName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sua Resposta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                hintText: 'Escreva a resposta oficial...',
                border: OutlineInputBorder(),
                helperText: 'Esta resposta será visível para todos os cidadãos',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Enviar Resposta',
              onPressed: _sendResponse,
              isLoading: _isLoading,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendResponse() async {
    if (_responseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite uma resposta')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.adminRespondToSuggestion(
        widget.suggestion.id,
        _responseController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resposta enviada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}