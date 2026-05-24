import 'package:flutter/material.dart';
import '../models/suggestion_model.dart';

class InteractionCard extends StatelessWidget {
  final SuggestionModel suggestion;
  final String currentUserId;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onVote;

  const InteractionCard({
    super.key,
    required this.suggestion,
    required this.currentUserId,
    required this.isAdmin,
    required this.onTap,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final hasVoted = suggestion.userVotes.contains(currentUserId);
    final hasAdminResponse = suggestion.adminResponse != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      suggestion.userName[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDate(suggestion.createdAt),
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
                      color: _getCategoryColor(suggestion.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      suggestion.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getCategoryColor(suggestion.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Título
              Text(
                suggestion.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Descrição
              Text(
                suggestion.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Resposta do Admin (se existir)
              if (hasAdminResponse) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade50, Colors.blue.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RESPOSTA DO ADMIN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              suggestion.adminResponse!,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Footer
              Row(
                children: [
                  // Botão de votar
                  InkWell(
                    onTap: onVote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasVoted ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 14,
                            color: hasVoted ? Colors.white : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${suggestion.votes}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hasVoted ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Comentários
                  Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Comentários',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(suggestion.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(suggestion.status),
                      style: TextStyle(
                        fontSize: 9,
                        color: _getStatusColor(suggestion.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mobilidade': return Colors.orange;
      case 'Iluminação': return Colors.amber;
      case 'Lazer': return Colors.green;
      case 'Saneamento': return Colors.blue;
      default: return Colors.grey;
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