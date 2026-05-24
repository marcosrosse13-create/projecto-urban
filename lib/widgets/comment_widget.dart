import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/firestore_service.dart';

class CommentWidget extends StatefulWidget {
  final CommentModel comment;
  final bool isAdmin;
  final String currentUserId;
  final String currentUserName;
  final VoidCallback onRefresh;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.isAdmin,
    required this.currentUserId,
    required this.currentUserName,
    required this.onRefresh,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _responseController = TextEditingController();
  bool _showResponseField = false;
  bool _isResponding = false;
  String? _adminResponse;

  @override
  void initState() {
    super.initState();
    _adminResponse = widget.comment.adminResponse;
  }

  bool get isOwner => widget.comment.userId == widget.currentUserId;
  bool get isCommentFromAdmin => widget.comment.userId == widget.currentUserId && widget.isAdmin;

  Future<void> _sendAdminResponse() async {
    if (_responseController.text.trim().isEmpty) return;

    setState(() => _isResponding = true);

    try {
      await _firestoreService.adminRespondToComment(
        widget.comment.id,
        _responseController.text.trim(),
      );

      setState(() {
        _adminResponse = _responseController.text.trim();
        _showResponseField = false;
        _responseController.clear();
      });

      widget.onRefresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resposta enviada ao cidadão!'),
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
      setState(() => _isResponding = false);
    }
  }

  Future<void> _deleteComment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Comentário'),
        content: const Text('Deseja eliminar este comentário?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteComment(widget.comment.id);
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentário eliminado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdminResponse = _adminResponse != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do Comentário
            Row(
              children: [
                // Avatar com identificação visual
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCommentFromAdmin
                        ? Colors.blue
                        : (widget.isAdmin
                        ? Colors.purple
                        : Colors.grey.shade400),
                  ),
                  child: Center(
                    child: Text(
                      widget.comment.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Informações do usuário
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.comment.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge de ADMIN
                          if (isCommentFromAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          // Badge de CIDADÃO (visível para admin)
                          if (widget.isAdmin && !isCommentFromAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'CIDADÃO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        _formatDate(widget.comment.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botão de eliminar (admin ou dono do comentário)
                if (widget.isAdmin || isOwner)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade500),
                    onPressed: _deleteComment,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Texto do Comentário
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCommentFromAdmin ? Colors.blue.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.comment.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isCommentFromAdmin ? Colors.blue.shade800 : Colors.grey.shade800,
                ),
              ),
            ),

            // RESPOSTA DO ADMIN AO COMENTÁRIO (VISÍVEL PARA TODOS)
            if (_adminResponse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'RESPOSTA DA ADMINISTRAÇÃO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (widget.comment.adminResponseAt != null)
                          Text(
                            _formatDate(widget.comment.adminResponseAt!),
                            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _adminResponse!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            // BOTÃO PARA ADMIN RESPONDER AO COMENTÁRIO
            if (widget.isAdmin && _adminResponse == null) ...[
              const SizedBox(height: 8),
              if (!_showResponseField)
                TextButton.icon(
                  onPressed: () => setState(() => _showResponseField = true),
                  icon: const Icon(Icons.reply, size: 16, color: Colors.blue),
                  label: const Text(
                    'Responder a este cidadão',
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _responseController,
                        decoration: const InputDecoration(
                          hintText: 'Digite a resposta para este cidadão...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        maxLines: 3,
                        autofocus: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showResponseField = false;
                                _responseController.clear();
                              });
                            },
                            child: const Text('Cancelar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isResponding ? null : _sendAdminResponse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: _isResponding
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Text('Enviar Resposta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],

            // INDICADOR PARA CIDADÃO: seu comentário foi respondido
            if (!widget.isAdmin && _adminResponse != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 12, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'A administração respondeu ao seu comentário',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade600,
                        fontStyle: FontStyle.italic,
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
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
  }
}