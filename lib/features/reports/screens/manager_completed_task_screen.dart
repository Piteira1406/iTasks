// features/reports/screens/manager_completed_tasks_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets (Lembre-se de usar o nome do seu projeto, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';
// import 'package:itasks/core/widgets/custom_button.dart'; // Não é usado aqui, mas pode ser preciso

class ManagerCompletedTasksScreen extends StatelessWidget {
  const ManagerCompletedTasksScreen({super.key});

  //
  // --- AS FUNÇÕES HELPER COMEÇAM AQUI (DENTRO DA CLASSE) ---
  //

  void _exportCSV() {
    // TODO: Chamar o CsvService
    // O serviço vai buscar os dados ao ReportProvider e gerar o ficheiro.
    // (Opcional) Mostrar um Snackbar de sucesso
  }

  // Helper para mostrar uma linha de informação
  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
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

  //
  // --- O MÉTODO build COMEÇA AQUI ---
  //
  @override
  Widget build(BuildContext context) {
    // --- Mock Data (Dados Falsos) ---
    // TODO: Estes dados virão do ReportProvider
    final List<Map<String, dynamic>> mockCompletedTasks = [
      {
        'title': 'Configurar o Firebase',
        'devName': 'Bruno Costa',
        'prevDays': 2,
        'realDays': 3, // Demorou mais 1 dia
      },
      {
        'title': 'Refactor da Homepage',
        'devName': 'Carla Dias',
        'prevDays': 2,
        'realDays': 1, // Demorou menos 1 dia
      },
    ];
    // --- Fim dos Dados Falsos ---

    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Concluídas (Gestor)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Botão de Exportar CSV (Req 1.124)
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportCSV, // Chama a função helper
            tooltip: 'Exportar para CSV',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockCompletedTasks.length,
        itemBuilder: (context, index) {
          final task = mockCompletedTasks[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Programador que executou
                    _buildInfoRow(
                      // Chama a função helper
                      context,
                      icon: Icons.person_outline,
                      label: 'Programador:',
                      value: task['devName'],
                    ),
                    const SizedBox(height: 8),

                    // Tempo Previsto vs. Real (Req 1.122)
                    _buildInfoRow(
                      // Chama a função helper
                      context,
                      icon: Icons.timer_outlined,
                      label: 'Tempo Previsto:',
                      value: '${task['prevDays']} dias',
                    ),
                    _buildInfoRow(
                      // Chama a função helper
                      context,
                      icon: Icons.check_circle_outline,
                      label: 'Tempo Real:',
                      value: '${task['realDays']} dias',
                      // Muda a cor se demorou mais que o previsto
                      valueColor: task['realDays'] > task['prevDays']
                          ? Colors.redAccent
                          : Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  } // <--- FIM DO MÉTODO build
} // <--- FIM DA CLASSE ManagerCompletedTasksScreen
