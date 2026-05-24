import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/suggestion_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/interaction_card.dart';
import '../widgets/loading_widget.dart';
import 'suggestion_detail_screen.dart';

class CitizenFeedScreen extends StatelessWidget {
  const CitizenFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final isAdmin = currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Consumer<SuggestionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'A carregar interações...');
          }

          if (provider.suggestions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma interação ainda',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAdmin
                        ? 'Os cidadãos ainda não criaram sugestões'
                        : 'Seja o primeiro a criar uma sugestão!',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Already listening to stream
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = provider.suggestions[index];
                return InteractionCard(
                  suggestion: suggestion,
                  currentUserId: currentUser!.id,
                  isAdmin: isAdmin,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SuggestionDetailScreen(suggestion: suggestion),
                      ),
                    );
                  },
                  onVote: () {
                    provider.voteSuggestion(suggestion.id, currentUser.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}