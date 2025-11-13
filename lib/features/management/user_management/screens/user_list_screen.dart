// features/management/user_management/screens/user_list_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets e o próximo ecrã
// (Lembre-se de usar o nome do seu projeto, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/management/user_management/screens/user_edit_screen.dart';
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
      body: _buildUserList(context), // Mostra a lista "mockada"
    );
  }

  // Widget temporário com dados falsos para design
  Widget _buildUserList(BuildContext context) {
    // Dados falsos (DEVE ser substituído pelo Provider)
    final List<Map<String, dynamic>> mockUsers = [
      {
        'id': 'gestor1',
        'name': 'Ana Silva',
        'email': 'ana.silva@itasks.com',
        'role': 'Gestor',
        'departamento': 'Mobile',
      },
      {
        'id': 'dev1',
        'name': 'Bruno Costa',
        'email': 'bruno.costa@itasks.com',
        'role': 'Programador',
        'nivel': 'Pleno',
        'gestorId': 'gestor1',
      },
      {
        'id': 'dev2',
        'name': 'Carla Dias',
        'email': 'carla.dias@itasks.com',
        'role': 'Programador',
        'nivel': 'Júnior',
        'gestorId': 'gestor1',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockUsers.length,
      itemBuilder: (context, index) {
        final user = mockUsers[index];
        final isManager = user['role'] == 'Gestor';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            // O seu widget de vidro
            child: ListTile(
              leading: Icon(
                isManager ? Icons.manage_accounts : Icons.person_outline,
                size: 40,
              ),
              title: Text(user['name']),
              subtitle: Text('${user['role']} | ${user['email']}'),
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
