import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/suggestion_provider.dart';
import 'add_suggestion_screen.dart';
import 'user_manager_screen.dart';
import 'citizen_feed_screen.dart';
import 'admin_feed_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).user;
    final isAdmin = currentUser?.role == 'admin';

    return DefaultTabController(
      length: isAdmin ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Urban Plan'),
          bottom: TabBar(
            tabs: isAdmin
                ? const [
              Tab(icon: Icon(Icons.forum), text: 'Interações'),
              Tab(icon: Icon(Icons.people), text: 'Cidadãos'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
            ]
                : const [
              Tab(icon: Icon(Icons.forum), text: 'Feed'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  currentUser?.name.split(' ')[0] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManagerScreen()),
                  );
                },
                tooltip: 'Gestão de Utilizadores',
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja realmente sair?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                }
              },
              tooltip: 'Sair',
            ),
          ],
        ),
        body: isAdmin
            ? const TabBarView(
          children: [
            CitizenFeedScreen(),   // Interações de cidadãos (admin vê)
            AdminFeedScreen(),     // Interações de administradores (admin vê)
            AdminPanelScreen(),    // Painel do admin
          ],
        )
            : const TabBarView(
          children: [
            CitizenFeedScreen(),   // Feed do cidadão (vê admin e cidadãos)
            AdminFeedScreen(),     // Interações do admin (cidadão vê)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSuggestionScreen()),
            );
          },
          child: const Icon(Icons.add),
          tooltip: 'Nova Sugestão',
        ),
      ),
    );
  }
}

// Painel do Administrador (apenas admin vê)
class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Painel de Controle do Administrador'),
    );
  }
}