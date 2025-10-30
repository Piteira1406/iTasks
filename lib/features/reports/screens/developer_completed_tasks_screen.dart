// features/reports/screens/developer_completed_tasks_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets (Lembre-se de usar o nome do seu projeto, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';

class DeveloperCompletedTasksScreen extends StatelessWidget {
  const DeveloperCompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Mock Data (Dados Falsos) ---
    // TODO: Estes dados virão do ReportProvider
    final List<Map<String, dynamic>> mockCompletedTasks = [
      {
        'title': 'Configurar o Firebase',
        'taskType': 'Setup',
        // DataInicioReal
        'startDate': DateTime(2025, 10, 1),
        // DataFimReal
        'endDate': DateTime(2025, 10, 3),
      },
      {
        'title': 'Refactor da Homepage',
        'taskType': 'Refactor',
        'startDate': DateTime(2025, 10, 5),
        'endDate': DateTime(2025, 10, 5), // Demorou 1 dia
      },
    ];
    // --- Fim dos Dados Falsos ---

    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas Concluídas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockCompletedTasks.length,
        itemBuilder: (context, index) {
          final task = mockCompletedTasks[index];
          // Calcular o tempo de execução (Req 1.121) 
          final duration = _calculateDuration(task['startDate'], task['endDate']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Tipo de Tarefa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task['title'],
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Chip(
                          label: Text(task['taskType']),
                          backgroundColor: Colors.greenAccent.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Tempo de Execução (Req 1.121)
                    _buildInfoRow(
                      context,
                      icon: Icons.check_circle_outline,
                      label: 'Tempo de Execução:',
                      value: duration,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper para calcular o tempo de execução em dias 
  String _calculateDuration(DateTime startDate, DateTime endDate) {
    // Adicionamos +1 para incluir o dia de início (ex: 1 a 3 de Outubro = 3 dias)
    final differenceInDays = endDate.difference(startDate).inDays + 1;
    
    if (differenceInDays == 1) {
      return '1 dia';
    }
    return '$differenceInDays dias';
  }

  // Helper para mostrar uma linha de informação
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}