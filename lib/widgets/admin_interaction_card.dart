import 'package:flutter/material.dart';

class AdminInteractionCard extends StatelessWidget {
  final String suggestionId;
  final String title;
  final String? adminResponse;
  final DateTime? adminResponseAt;
  final String status;

  const AdminInteractionCard({
    super.key,
    required this.suggestionId,
    required this.title,
    this.adminResponse,
    this.adminResponseAt,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Admin
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administração',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.purple,
                        ),
                      ),
                      if (adminResponseAt != null)
                        Text(
                          _formatDate(adminResponseAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Título da sugestão
            Text(
              'Sugestão: $title',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Resposta do Admin
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.purple.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.reply, size: 14, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESPOSTA OFICIAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          adminResponse ?? 'Aguardando resposta...',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'há ${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return 'há ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'há ${difference.inMinutes} minutos';
    } else {
      return 'agora mesmo';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'in_progress': return 'Em Progresso';
      case 'completed': return 'Concluído';
      default: return 'Pendente';
    }
  }
}