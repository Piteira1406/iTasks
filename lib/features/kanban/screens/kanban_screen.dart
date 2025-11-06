// features/kanban/screens/kanban_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Imports de Lógica (Novos) ---
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/core/widgets/loading_spinner.dart';
import 'package:itasks/core/models/task_model.dart'; // Importa o modelo real

// --- Imports da UI (Existentes) ---
import 'package:itasks/features/kanban/widgets/kanban_column_widget.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';

// --- Imports para o Menu de Teste (Mantidos) ---
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
      context.read<KanbanProvider>().tasks;
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
    final authProvider = context.watch<AuthProvider>();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // --- Menu de Teste (COM A CORREÇÃO) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Menu de Teste de UI"),
              accountEmail: Text(
                isManager ? "Modo: Gestor" : "Modo: Programador",
              ),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.build)),
            ),
            // ...
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text("Kanban: Ver Tarefa (Programador)"),
              onTap: () {
                // --- INÍCIO DA CORREÇÃO ---
                // Esta tarefa "mock" agora usa a estrutura real do
                // seu TaskModel (baseado na imagem image_dcb15f.png)
                final mockTask = Task(
                  id: 'mock-id',
                  description: 'Tarefa de Teste (Modo Leitura)',
                  taskStatus: 'ToDo',
                  order: 1,
                  storyPoints: 5,
                  creationDate: DateTime.now(),
                  previsionEndDate: DateTime.now().add(Duration(days: 5)),
                  previsionStartDate: DateTime.now(),
                  realEndDate: DateTime.timestamp(),
                  realStartDate: DateTime.timestamp(),
                  idManager: 'mock-manager-id',
                  idDeveloper: 'mock-dev-id',
                  idTaskType: 'mock-type-id (ex: Bug)',
                );
                // --- FIM DA CORREÇÃO ---

                _navigateTo(
                  context,
                  TaskDetailsScreen(
                    isReadOnly: true,
                    task: mockTask, // Passa a tarefa mock corrigida
                  ),
                );
              },
            ),

            // ... (Resto dos ListTiles do menu de teste) ...
            ListTile(
              leading: Icon(Icons.label),
              title: Text("Gestão: Tipos de Tarefa"),
              onTap: () => _navigateTo(context, const TaskTypeScreen()),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text("Gestão: Lista de Utilizadores"),
              onTap: () => _navigateTo(context, const UserListScreen()),
            ),
            ListTile(
              leading: Icon(Icons.add_task),
              title: Text("Kanban: Criar Tarefa (Gestor)"),
              onTap: () => _navigateTo(
                context,
                const TaskDetailsScreen(isReadOnly: false, task: null),
              ),
            ),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text("Relatório: Em Curso (Gestor)"),
              onTap: () =>
                  _navigateTo(context, const ManagerOngoingTasksScreen()),
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text("Relatório: Concluídas (Gestor)"),
              onTap: () =>
                  _navigateTo(context, const ManagerCompletedTasksScreen()),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text("Relatório: Concluídas (Programador)"),
              onTap: () =>
                  _navigateTo(context, const DeveloperCompletedTasksScreen()),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout (Voltar ao Login)"),
              onTap: () {
                context.read<AuthProvider>().signOut();
              },
            ),
          ],
        ),
      ),

      // --- Fim do Menu de Teste ---
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
