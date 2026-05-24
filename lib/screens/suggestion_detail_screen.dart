import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/suggestion_model.dart';
import '../models/comment_model.dart';
import '../providers/auth_provider.dart';
import '../providers/suggestion_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/comment_widget.dart';

class SuggestionDetailScreen extends StatefulWidget {
  final SuggestionModel suggestion;

  const SuggestionDetailScreen({super.key, required this.suggestion});

  @override
  State<SuggestionDetailScreen> createState() => _SuggestionDetailScreenState();
}

class _SuggestionDetailScreenState extends State<SuggestionDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isAdmin = false;
  bool _isResponding = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkAdmin();
  }

  void _loadComments() {
    _firestoreService.getComments(widget.suggestion.id).listen((comments) {
      if (mounted) {
        setState(() {
          _comments = comments;
        });
      }
    });
  }

  void _refreshComments() {
    setState(() {
      _refreshKey++;
    });
    _loadComments();
  }

  void _checkAdmin() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (mounted) {
      setState(() {
        _isAdmin = user?.role == 'admin';
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    if (currentUser == null) return;

    final comment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      suggestionId: widget.suggestion.id,
      userId: currentUser.id,
      userName: currentUser.name,
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _firestoreService.addComment(comment);
    _commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAdmin
            ? 'Comentário enviado como Administrador'
            : 'Comentário enviado! O administrador poderá responder.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    await _firestoreService.updateSuggestionStatus(widget.suggestion.id, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para: ${_getStatusText(newStatus)}')),
      );
    }
  }

  Future<void> _respondToSuggestion() async {
    final TextEditingController responseController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder à Sugestão'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            hintText: 'Digite a resposta oficial...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (result == true && responseController.text.trim().isNotEmpty) {
      setState(() => _isResponding = true);
      try {
        await _firestoreService.adminRespondToSuggestion(
          widget.suggestion.id,
          responseController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resposta enviada ao cidadão!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isResponding = false);
        }
      }
    }
  }

  Future<void> _deleteSuggestion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sugestão'),
        content: const Text('Tem certeza que deseja eliminar esta sugestão?'),
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
      await Provider.of<SuggestionProvider>(context, listen: false)
          .deleteSuggestion(widget.suggestion.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sugestão eliminada!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final hasVoted = widget.suggestion.userVotes.contains(currentUser?.id);
    final isAuthor = widget.suggestion.userId == currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.suggestion.title),
        actions: [
          if (_isAdmin || isAuthor)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSuggestion,
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: _isResponding
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.suggestion.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(widget.suggestion.status),
                    style: TextStyle(color: _getStatusColor(widget.suggestion.status)),
                  ),
                ),
                const Spacer(),
                if (_isAdmin)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.edit),
                    onSelected: _updateStatus,
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'pending', child: Text('Pendente')),
                      const PopupMenuItem(value: 'in_progress', child: Text('Em Progresso')),
                      const PopupMenuItem(value: 'completed', child: Text('Concluído')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Categoria
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(widget.suggestion.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.suggestion.category,
                style: TextStyle(color: _getCategoryColor(widget.suggestion.category)),
              ),
            ),
            const SizedBox(height: 16),

            // Descrição
            Text(
              widget.suggestion.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, 'Autor', widget.suggestion.userName),
                    const Divider(),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Data',
                      '${widget.suggestion.createdAt.day}/${widget.suggestion.createdAt.month}/${widget.suggestion.createdAt.year}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // RESPOSTA DO ADMIN À SUGESTÃO
            if (widget.suggestion.adminResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'RESPOSTA OFICIAL DA ADMINISTRAÇÃO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        if (widget.suggestion.adminResponseAt != null)
                          Text(
                            _formatDate(widget.suggestion.adminResponseAt!),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.suggestion.adminResponse!),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Botão para ADMIN responder
            if (_isAdmin && widget.suggestion.adminResponse == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OutlinedButton.icon(
                  onPressed: _respondToSuggestion,
                  icon: const Icon(Icons.reply),
                  label: const Text('Responder a esta Sugestão'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                ),
              ),

            // Votação
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: hasVoted ? 'Remover Apoio' : 'Apoiar',
                    icon: hasVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                    onPressed: () {
                      Provider.of<SuggestionProvider>(context, listen: false)
                          .voteSuggestion(widget.suggestion.id, currentUser!.id);
                    },
                    backgroundColor: hasVoted ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.suggestion.votes}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('Apoios', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seção de Comentários
            Row(
              children: [
                const Text(
                  'Comentários',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_comments.length}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Adicionar Comentário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: _isAdmin
                              ? 'Escreva um comentário como Administrador...'
                              : 'Escreva um comentário...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Lista de Comentários com interação bidirecional
            if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Sem comentários ainda',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isAdmin
                            ? 'Seja o primeiro a comentar como Administrador'
                            : 'Seja o primeiro a comentar',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                key: ValueKey(_refreshKey),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return CommentWidget(
                    comment: comment,
                    isAdmin: _isAdmin,
                    currentUserId: currentUser!.id,
                    currentUserName: currentUser.name,
                    onRefresh: _refreshComments,
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Mobilidade': return Colors.orange;
      case 'Iluminação': return Colors.amber;
      case 'Lazer': return Colors.green;
      case 'Saneamento': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}