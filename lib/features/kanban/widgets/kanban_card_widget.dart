// lib/features/kanban/widgets/kanban_card_widget.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart'; // <-- O ficheiro que contém 'class Task'
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
// TODO: Importar providers para mostrar nomes
// import 'package:provider/provider.dart';
// import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';
// import 'package:itasks/features/management/task_type_management/providers/task_type_provider.dart';

class KanbanCardWidget extends StatelessWidget {
  final Task task; // <-- 1. Usa a classe 'Task' (como pediu)
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
    // TODO: Usar os providers para fazer 'lookup' dos nomes
    // final devName = context.watch<UserManagementProvider>().getUserNameById(task.idDeveloper);
    // final taskTypeName = context.watch<TaskTypeProvider>().getTaskTypeNameById(task.idTaskType);

    // Temporário: Mostra os IDs até os providers estarem ligados
    final String devName = task.idDeveloper;
    final String taskTypeName = task.idTaskType;

    return Padding(
      // Padding à volta do cartão
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: GlassCard(
        child: InkWell(
          onTap: () => _navigateToDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // --- 2. ESTA É A CORREÇÃO ---
              // Faz o cartão "encolher" ao tamanho do seu conteúdo,
              // corrigindo o problema da imagem image_aaf489.png
              mainAxisSize: MainAxisSize.min,
              // --- FIM DA CORREÇÃO ---
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description, // <-- 3. Usa 'description' do Task
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
