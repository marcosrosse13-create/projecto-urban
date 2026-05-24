import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';

class UserManagerScreen extends StatefulWidget {
  const UserManagerScreen({super.key});

  @override
  State<UserManagerScreen> createState() => _UserManagerScreenState();
}

class _UserManagerScreenState extends State<UserManagerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _filter = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Utilizadores'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por nome ou email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildFilterChip('Todos', 0),
                    _buildFilterChip('Cidadãos', 1),
                    _buildFilterChip('Administradores', 2),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'A carregar utilizadores...');
          }

          var users = snapshot.data!.docs;

          if (_filter == 'Cidadãos') {
            users = users.where((doc) => doc['role'] == 'citizen').toList();
          } else if (_filter == 'Administradores') {
            users = users.where((doc) => doc['role'] == 'admin').toList();
          }

          if (_searchQuery.isNotEmpty) {
            users = users.where((doc) {
              final name = doc['name']?.toString().toLowerCase() ?? '';
              final email = doc['email']?.toString().toLowerCase() ?? '';
              return name.contains(_searchQuery) || email.contains(_searchQuery);
            }).toList();
          }

          final totalUsers = users.length;
          final totalCitizens = users.where((doc) => doc['role'] == 'citizen').length;
          final totalAdmins = users.where((doc) => doc['role'] == 'admin').length;
          final activeUsers = users.where((doc) => doc['isActive'] == true).length;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum utilizador encontrado',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total', totalUsers.toString(), Icons.people),
                    _buildStatCard('Cidadãos', totalCitizens.toString(), Icons.person),
                    _buildStatCard('Admins', totalAdmins.toString(), Icons.admin_panel_settings),
                    _buildStatCard('Ativos', activeUsers.toString(), Icons.check_circle),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final isActive = userData['isActive'] ?? true;
                    final role = userData['role'] ?? 'citizen';
                    final isAdmin = role == 'admin';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin ? Colors.blue : Colors.green,
                          radius: 24,
                          child: Text(
                            (userData['name']?[0] ?? 'U').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          userData['name'] ?? 'Sem nome',
                          style: TextStyle(
                            decoration: !isActive ? TextDecoration.lineThrough : null,
                            color: !isActive ? Colors.grey : null,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userData['email'] ?? 'Sem email'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAdmin ? Colors.blue.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                                        size: 12,
                                        color: isAdmin ? Colors.blue.shade800 : Colors.green.shade800,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAdmin ? 'Administrador' : 'Cidadão',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isAdmin ? Colors.blue.shade800 : Colors.green.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActive ? 'Ativo' : 'Suspenso',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'role',
                              child: Row(
                                children: [
                                  Icon(Icons.switch_account, size: 20),
                                  SizedBox(width: 12),
                                  Text('Alterar Papel'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'status',
                              child: Row(
                                children: [
                                  Icon(Icons.block, size: 20),
                                  SizedBox(width: 12),
                                  Text('Suspender/Ativar'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) async {
                            if (value == 'role') {
                              final newRole = isAdmin ? 'citizen' : 'admin';
                              await _firestoreService.updateUserRole(user.id, newRole);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Papel alterado para ${newRole == 'admin' ? "Administrador" : "Cidadão"}'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            } else if (value == 'status') {
                              await _firestoreService.updateUserStatus(user.id, !isActive);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isActive ? 'Utilizador suspenso' : 'Utilizador ativado'),
                                    backgroundColor: isActive ? Colors.orange : Colors.green,
                                  ),
                                );
                              }
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected =
        (index == 0 && _filter == 'Todos') ||
            (index == 1 && _filter == 'Cidadãos') ||
            (index == 2 && _filter == 'Administradores');

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (index == 0) _filter = 'Todos';
            if (index == 1) _filter = 'Cidadãos';
            if (index == 2) _filter = 'Administradores';
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}