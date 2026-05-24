import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/admin_interaction_card.dart';
import '../widgets/loading_widget.dart';

class AdminFeedScreen extends StatelessWidget {
  const AdminFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getAdminInteractions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'A carregar interações do admin...');
          }

          final interactions = snapshot.data!.docs;

          if (interactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma interação do administrador ainda',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O administrador ainda não respondeu a nenhuma sugestão',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: interactions.length,
              itemBuilder: (context, index) {
                final interaction = interactions[index];
                final data = interaction.data() as Map<String, dynamic>;
                return AdminInteractionCard(
                  suggestionId: interaction.id,
                  title: data['title'] ?? '',
                  adminResponse: data['adminResponse'],
                  adminResponseAt: (data['adminResponseAt'] as Timestamp?)?.toDate(),
                  status: data['status'] ?? 'pending',
                );
              },
            ),
          );
        },
      ),
    );
  }
}