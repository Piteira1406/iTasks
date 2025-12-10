// lib/features/kanban/widgets/kanban_card_widget.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';

class KanbanCardWidget extends StatelessWidget {
  final Task task;
  final bool isReadOnly;

  const KanbanCardWidget({
    super.key,
    required this.task,
    required this.isReadOnly,
  });

  // Função de 'clique' para ver detalhes
  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailsScreen(task: task, isReadOnly: isReadOnly),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String devName = task.idDeveloper.toString();
    final String taskTypeName = task.idTaskType.toString();

    return Padding(
      // Padding à volta do cartão
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: GlassCard(
        child: InkWell(
          onTap: () => _navigateToDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(
                    taskTypeName, // <-- 4. Usa 'idTaskType' do Task
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        devName, // <-- 5. Usa 'idDeveloper' do Task
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    if (task.storyPoints != 0)
                      Text(
                        '${task.storyPoints} SP', // 6. Usa 'storyPoints' do Task
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
