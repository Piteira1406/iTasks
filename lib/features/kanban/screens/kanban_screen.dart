// features/kanban/screens/kanban_screen.dart

import 'package:flutter/material.dart';
// Importe os widgets e ecrãs
import 'package:itasks/features/kanban/widgets/kanban_column_widget.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
// (Opcional) import 'package:itasks/core/widgets/scroll_frost_appbar.dart';

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
