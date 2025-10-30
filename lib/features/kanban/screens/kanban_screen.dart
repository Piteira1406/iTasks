// features/kanban/screens/kanban_screen.dart

import 'package:flutter/material.dart';
// Importe os widgets e ecrãs
import 'package:itasks/features/kanban/widgets/kanban_column_widget.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
// (Opcional) import 'package:itasks/core/widgets/scroll_frost_appbar.dart';

// --- Imports para o Menu de Teste ---
// (Use o nome do seu projeto, ex: 'itasks')
import 'package:itasks/features/auth/screens/login_screen.dart';
import 'package:itasks/features/management/task_type_management/screens/task_type_screen.dart';
import 'package:itasks/features/management/user_management/screens/user_list_screen.dart';
import 'package:itasks/features/reports/screens/manager_ongoing_tasks_screen.dart';
import 'package:itasks/features/reports/screens/manager_completed_task_screen.dart'; // Corrigi o 'tasks'
import 'package:itasks/features/reports/screens/developer_completed_tasks_screen.dart';
// --- Fim dos Imports de Teste ---

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  // TODO: Esta lógica virá do AuthProvider
  final bool _isManager =
      true; // Mude para 'false' para testar como Programador
  final String _userName = "Utilizador Teste"; // Virá do AuthProvider

  // --- Mock Data (Dados Falsos) ---
  // TODO: Estes dados virão do KanbanProvider
  final List<dynamic> _toDoTasks = [
    {
      'id': 't1',
      'title': 'Implementar Login Screen',
      'type': 'Feature',
      'devName': 'Bruno',
      'order': 1,
    },
    {
      'id': 't2',
      'title': 'Corrigir bug no iOS',
      'type': 'Bug',
      'devName': 'Carla',
      'order': 2,
    },
  ];
  final List<dynamic> _doingTasks = [
    {
      'id': 't3',
      'title': 'Criar modelos de dados',
      'type': 'Feature',
      'devName': 'Carla',
      'order': 1,
    },
  ];
  final List<dynamic> _doneTasks = [
    {
      'id': 't4',
      'title': 'Configurar o Firebase',
      'type': 'Setup',
      'devName': 'Bruno',
      'order': 1,
    },
  ];
  // --- Fim dos Dados Falsos ---

  void _navigateToCreateTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          task: null, // 'null' significa criar
          isReadOnly: false, // Gestor pode editar
        ),
      ),
    );
  }

  // --- INÍCIO: Helper para o Menu de Teste ---
  // Helper temporário para navegar
  void _navigateTo(BuildContext context, Widget screen) {
    // Fecha o Drawer antes de navegar
    Navigator.of(context).pop();
    // Navega para o novo ecrã
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
  // --- FIM: Helper para o Menu de Teste ---

  @override
  Widget build(BuildContext context) {
    // Usamos o PageController para permitir 'swipe' entre colunas
    final PageController controller = PageController(viewportFraction: 0.9);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban iTasks'),
        // Mostra o nome do utilizador logado
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Bem-vindo(a), $_userName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // --- INÍCIO DO CÓDIGO DE TESTE (Drawer) ---
      // Adiciona esta propriedade 'drawer'
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("Menu de Teste de UI"),
              accountEmail: Text("Navegação Rápida"),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.build)),
            ),

            // --- Ecrãs de Gestão (Gestor) ---
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Gestão (Gestor)"),
            ),
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

            // --- Ecrãs Kanban (Teste de Modos) ---
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Kanban (Teste de Modos)"),
            ),
            ListTile(
              leading: Icon(Icons.add_task),
              title: Text("Kanban: Criar Tarefa (Gestor)"),
              // Abre o ecrã de detalhes em modo "criar"
              onTap: () => _navigateTo(
                context,
                const TaskDetailsScreen(isReadOnly: false, task: null),
              ),
            ),
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text("Kanban: Ver Tarefa (Programador)"),
              // Abre o ecrã de detalhes em modo "ver" com dados falsos
              onTap: () => _navigateTo(
                context,
                TaskDetailsScreen(
                  isReadOnly: true,
                  task: {
                    // Mock de 1 tarefa
                    'title': 'Tarefa de Teste (Modo Leitura)',
                    'order': 1,
                    'devName': 'Programador Teste',
                    'type': 'Bug',
                  },
                ),
              ),
            ),

            // --- Ecrãs de Relatórios ---
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("Relatórios"),
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

            // --- Logout ---
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Voltar ao Login"),
              onTap: () {
                // TODO: Chamar context.read<AuthProvider>().logout()
                // Por agora, apenas substituímos o ecrã:
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      // --- FIM DO CÓDIGO DE TESTE ---

      // O Gestor vê o botão de Adicionar, o Programador não
      floatingActionButton: _isManager
          ? FloatingActionButton(
              onPressed: () => _navigateToCreateTask(context),
              child: Icon(Icons.add_task),
            )
          : null,
      body: PageView(
        controller: controller,
        children: [
          // Coluna 1: ToDo
          KanbanColumnWidget(
            title: 'ToDo',
            titleColor: Theme.of(context).colorScheme.primary, // Cor de status
            tasks: _toDoTasks,
            isReadOnly: !_isManager,
          ),
          // Coluna 2: Doing
          KanbanColumnWidget(
            title: 'Doing',
            titleColor: Colors.orangeAccent, // Cor de status
            tasks: _doingTasks,
            isReadOnly: !_isManager,
          ),
          // Coluna 3: Done
          KanbanColumnWidget(
            title: 'Done',
            titleColor: Colors.greenAccent, // Cor de status
            tasks: _doneTasks,
            isReadOnly: !_isManager,
          ),
        ],
      ),
    );
  }
}
