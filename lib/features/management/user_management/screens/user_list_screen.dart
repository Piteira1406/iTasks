// features/management/user_management/screens/user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importe os seus widgets e o próximo ecrã
// (Lembre-se de usar o nome do seu projeto, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/management/user_management/screens/user_edit_screen.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';
// (Opcional, se quiser usar a sua appbar)
// import 'package:itasks/core/widgets/scroll_frost_appbar.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  // Função para navegar para o ecrã de edição/criação
  void _navigateToEditScreen(BuildContext context, {dynamic user}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserEditScreen(
          // Se o 'user' for nulo, o ecrã saberá que é para "criar"
          // Se for preenchido, será para "editar"
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão de Utilizadores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(context), // Criar novo
        child: Icon(Icons.add),
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, userManagementProvider, child) {
          if (userManagementProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final users = userManagementProvider.users;

          if (users.isEmpty) {
            return Center(
              child: Text('Nenhum utilizador encontrado'),
            );
          }

          return _buildUserList(context, users);
        },
      ),
    );
  }

  // Widget para mostrar a lista de utilizadores
  Widget _buildUserList(BuildContext context, List users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isManager = user.type == 'Manager';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            // O seu widget de vidro
            child: ListTile(
              leading: Icon(
                isManager ? Icons.manage_accounts : Icons.person_outline,
                size: 40,
              ),
              title: Text(user.name),
              subtitle: Text('${user.type} | ${user.email}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão Editar
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white70),
                    onPressed: () {
                      _navigateToEditScreen(context, user: user); // Editar
                    },
                  ),
                  // Botão Apagar
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      // TODO: Chamar o Provider para apagar
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
