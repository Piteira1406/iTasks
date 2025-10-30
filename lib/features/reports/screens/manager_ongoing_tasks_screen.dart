// features/reports/screens/manager_ongoing_tasks_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets (Lembre-se de usar o nome do seu projeto, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';

class ManagerOngoingTasksScreen extends StatelessWidget {
  const ManagerOngoingTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Mock Data (Dados Falsos) ---
    // TODO: Estes dados virão do ReportProvider
    final List<Map<String, dynamic>> mockOngoingTasks = [
      {
        'title': 'Implementar Login Screen',
        'devName': 'Bruno Costa',
        'status': 'ToDo',
        // DataFimPrevista: Daqui a 5 dias
        'endDate': DateTime.now().add(const Duration(days: 5)), 
      },
      {
        'title': 'Criar modelos de dados',
        'devName': 'Carla Dias',
        'status': 'Doing',
         // DataFimPrevista: Há 2 dias atrás (atrasada)
        'endDate': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'title': 'Corrigir bug no iOS',
        'devName': 'Bruno Costa',
        'status': 'ToDo',
         // DataFimPrevista: Para hoje
        'endDate': DateTime.now(),
      },
    ];
    // --- Fim dos Dados Falsos ---

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas em Curso'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockOngoingTasks.length,
        itemBuilder: (context, index) {
          final task = mockOngoingTasks[index];
          // Esta é a lógica chave (Req 1.123)
          final timeDifference = _calculateTimeDifference(task['endDate']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da Tarefa e Estado
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
                          label: Text(task['status']),
                          backgroundColor: task['status'] == 'Doing' 
                              ? Colors.orangeAccent.withOpacity(0.5) 
                              : Colors.blueAccent.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Programador
                    _buildInfoRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'Programador:',
                      value: task['devName'],
                    ),
                    const SizedBox(height: 8),

                    // Tempo em Falta / Atraso (Req 1.123)
                    _buildInfoRow(
                      context,
                      icon: Icons.timer_outlined,
                      label: timeDifference['label'], // "Tempo em Falta:" ou "Atraso:"
                      value: timeDifference['value'], // "5 dias" ou "2 dias"
                      valueColor: timeDifference['color'], // Verde ou Vermelho
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

  // Helper para calcular o tempo em falta/atraso (Req 1.123) 
  Map<String, dynamic> _calculateTimeDifference(DateTime endDate) {
    final now = DateTime.now();
    // Normalizamos as datas para ignorar as horas
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(endDate.year, endDate.month, endDate.day);
    
    final differenceInDays = targetDate.difference(today).inDays;

    if (differenceInDays < 0) {
      return {
        'label': 'Atraso:',
        'value': '${differenceInDays.abs()} dias',
        'color': Colors.redAccent, // Cor para atrasos
      };
    } else if (differenceInDays == 0) {
      return {
        'label': 'Termina Hoje',
        'value': '',
        'color': Colors.orangeAccent, // Cor para "hoje"
      };
    } else {
      return {
        'label': 'Tempo em Falta:',
        'value': '$differenceInDays dias',
        'color': Colors.greenAccent, // Cor para "em falta"
      };
    }
  }

  // Helper para mostrar uma linha de informação
  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
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
              color: valueColor ?? Colors.white,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}