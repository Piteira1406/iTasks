// features/kanban/widgets/kanban_column_widget.dart

import 'package:flutter/material.dart';
import 'package:itasks/features/kanban/widgets/task_card_widget.dart';
// Importe o ecrã de detalhes para onde vamos navegar
import 'package:itasks/features/kanban/screens/task_details_screen.dart';

class KanbanColumnWidget extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<dynamic> tasks; // Lista de tarefas (mockadas)
  final bool isReadOnly; // Para saber se o utilizador é Programador

  const KanbanColumnWidget({
    super.key,
    required this.title,
    required this.tasks,
    this.titleColor = Colors.white,
    required this.isReadOnly,
  });

  void _navigateToDetails(BuildContext context, {dynamic task}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(
          task: task,
          // O Programador só pode ver, não editar.
          isReadOnly: isReadOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos LayoutBuilder para que a coluna se adapte ao ecrã
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // Um 'glass card' ligeiramente diferente para a coluna
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da Coluna (ToDo, Doing, Done)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Lista de Tarefas
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    // Este é o cartão que criámos no passo 1
                    return TaskCardWidget(
                      title: task['title'],
                      taskType: task['type'],
                      developerName: task['devName'],
                      order: task['order'],
                      onTap: () {
                        // Ao clicar, navega para os detalhes
                        _navigateToDetails(context, task: task);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
