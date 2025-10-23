// features/kanban/widgets/task_card_widget.dart

import 'package:flutter/material.dart';
// Lembre-se de usar o nome do seu projeto, ex: 'itasks'
import 'package:itasks/core/widgets/glass_card.dart';

class TaskCardWidget extends StatelessWidget {
  final String title;
  final String taskType;
  final String developerName;
  final int order;
  final VoidCallback onTap; // Função para navegar para os detalhes

  const TaskCardWidget({
    super.key,
    required this.title,
    required this.taskType,
    required this.developerName,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        // Adiciona o efeito de 'clique'
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: GlassCard(
          // O seu widget de vidro
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da Tarefa
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tipo de Tarefa (ex: Bug, Feature)
                Chip(
                  label: Text(taskType, style: TextStyle(fontSize: 12)),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.5),
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Programador Atribuído
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(developerName, style: TextStyle(fontSize: 12)),
                      ],
                    ),

                    // Ordem de Execução
                    Row(
                      children: [
                        Icon(Icons.priority_high, size: 16),
                        const SizedBox(width: 4),
                        Text(order.toString(), style: TextStyle(fontSize: 12)),
                      ],
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
