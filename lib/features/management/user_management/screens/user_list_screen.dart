import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Imports do projeto
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/management/user_management/screens/user_edit_screen.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';
import 'package:itasks/core/models/app_user_model.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega a lista de utilizadores assim que o ecrã abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
    });
  }

  // Função para navegar para o ecrã de edição/criação
  void _navigateToEditScreen(BuildContext context, {AppUser? user}) {
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
        title: const Text('Gestão de Utilizadores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(context), // Criar novo
        child: const Icon(Icons.add),
      ),
      // Usamos Consumer para reconstruir a lista quando os dados mudam
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          // 1. Estado de Loading
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Lista Vazia
          if (provider.users.isEmpty) {
            return const Center(child: Text("Nenhum utilizador encontrado."));
          }

          // 3. Lista com Dados Reais
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.users.length,
            itemBuilder: (context, index) {
              final AppUser user = provider.users[index];
              final isManager = user.type == 'Manager';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isManager
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        isManager
                            ? Icons.manage_accounts
                            : Icons.person_outline,
                        color: isManager ? Colors.orange : Colors.blue,
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.type, // Mostra "Manager" ou "Programador"
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão Editar
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () {
                            _navigateToEditScreen(context, user: user);
                          },
                        ),
                        // Botão Apagar (Visual apenas, provider precisa do método delete)
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            // TODO: provider.deleteUser(user.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Funcionalidade 'Apagar' ainda não implementada",
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
