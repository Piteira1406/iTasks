// features/kanban/screens/kanban_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports de Lógica ---
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/core/widgets/loading_spinner.dart';
import 'package:itasks/core/models/task_model.dart';
// 1. IMPORTAR O THEME PROVIDER
import 'package:itasks/core/providers/theme_provider.dart';

// --- Imports da UI ---
import 'package:itasks/features/kanban/widgets/kanban_column_widget.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
import 'package:itasks/core/widgets/glass_card.dart'; // Importar o GlassCard

// --- Imports para o Menu de Teste ---
import 'package:itasks/features/auth/screens/login_screen.dart';
import 'package:itasks/features/management/task_type_management/screens/task_type_screen.dart';
import 'package:itasks/features/management/user_management/screens/user_list_screen.dart';
import 'package:itasks/features/reports/screens/manager_ongoing_tasks_screen.dart';
import 'package:itasks/features/reports/screens/manager_completed_task_screen.dart';
import 'package:itasks/features/reports/screens/developer_completed_tasks_screen.dart';
// --- Fim dos Imports ---

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanbanProvider>().fetchTasks();
    });
  }

  void _navigateToCreateTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: null, isReadOnly: false),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(viewportFraction: 0.9);

    // 2. OUVIR OS DOIS PROVIDERS
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>(); // <-- Para o Toggle

    final bool isManager = authProvider.appUser?.type == 'Gestor';
    final String userName = authProvider.appUser?.name ?? 'Utilizador';

    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban iTasks'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Bem-vindo(a), $userName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        // O AppBar transparente já deve estar a ser definido pelo novo AppTheme
      ),

      // --- 3. DRAWER COM EFEITO GLASS E TOGGLE ---
      drawer: Drawer(
        backgroundColor: Colors.transparent, // <-- Fundo do Drawer transparente
        elevation: 0, // <-- Sem sombra
        child: GlassCard(
          // Usa o GlassCard como fundo real
          borderRadius: BorderRadius.zero, // <-- Remove cantos redondos
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text("Menu de Teste de UI"),
                accountEmail: Text(
                  isManager ? "Modo: Gestor" : "Modo: Programador",
                ),
                currentAccountPicture: CircleAvatar(child: Icon(Icons.build)),
                // Faz o cabeçalho transparente para o 'glass' aparecer
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
              ),

              // --- Ecrãs de Gestão (Gestor) ---
              ListTile(
                leading: Icon(Icons.label_outline),
                title: Text("Gestão: Tipos de Tarefa"),
                onTap: () => _navigateTo(context, const TaskTypeScreen()),
              ),
              ListTile(
                leading: Icon(Icons.people_outline),
                title: Text("Gestão: Lista de Utilizadores"),
                onTap: () => _navigateTo(context, const UserListScreen()),
              ),

              // --- Ecrãs de Relatórios ---
              const Divider(),
              ListTile(
                leading: Icon(Icons.timer_outlined),
                title: Text("Relatório: Em Curso (Gestor)"),
                onTap: () =>
                    _navigateTo(context, const ManagerOngoingTasksScreen()),
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text("Relatório: Concluídas (Gestor)"),
                onTap: () =>
                    _navigateTo(context, const ManagerCompletedTasksScreen()),
              ),
              ListTile(
                leading: Icon(Icons.check_outlined),
                title: Text("Relatório: Concluídas (Programador)"),
                onTap: () =>
                    _navigateTo(context, const DeveloperCompletedTasksScreen()),
              ),

              // --- Logout ---
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text("Logout (Voltar ao Login)"),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                },
              ),

              // --- 4. ADICIONADO O TOGGLE DE TEMA ---
              ListTile(
                leading: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                title: Text(
                  themeProvider.themeMode == ThemeMode.dark
                      ? 'Modo Claro'
                      : 'Modo Escuro',
                ),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (bool newValue) {
                    // Usamos 'read' dentro de um callback
                    context.read<ThemeProvider>().toggleTheme();
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // --- Fim do Menu ---
      floatingActionButton: isManager
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateTask(context),
              child: Icon(Icons.add_task),
            )
          : null,

      body: Consumer<KanbanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingSpinner();
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text('Erro: ${provider.errorMessage}'));
          }
          return PageView(
            controller: controller,
            children: [
              KanbanColumnWidget(
                title: 'ToDo',
                titleColor: Theme.of(context).colorScheme.primary,
                tasks: provider.todoTasks,
                isReadOnly: !isManager,
              ),
              KanbanColumnWidget(
                title: 'Doing',
                titleColor: Colors.orangeAccent,
                tasks: provider.doingTasks,
                isReadOnly: !isManager,
              ),
              KanbanColumnWidget(
                title: 'Done',
                titleColor: Colors.greenAccent,
                tasks: provider.doneTasks,
                isReadOnly: !isManager,
              ),
            ],
          );
        },
      ),
    );
  }
}
