import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';
import 'package:itasks/features/reports/widgets/report_filters.dart';
import 'package:itasks/features/reports/widgets/statistics_cards.dart';
import 'package:itasks/features/reports/widgets/tasks_table.dart';
import 'package:itasks/features/reports/widgets/storypoints_estimation_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          // Botão de exportar estatísticas
          if (reportProvider.tasks.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.download),
              tooltip: 'Exportar',
              onSelected: (value) async {
                if (value == 'tasks') {
                  await _exportTasks(context);
                } else if (value == 'statistics') {
                  await _exportStatistics(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'tasks',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart),
                      SizedBox(width: 8),
                      Text('Exportar Tarefas'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'statistics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('Exportar Estatísticas'),
                    ],
                  ),
                ),
              ],
            ),
          // Botão de limpar filtros
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: reportProvider.tasks.isEmpty
                ? null
                : () {
                    reportProvider.clearFilters();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Filtros limpos'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            tooltip: 'Limpar Filtros',
          ),
        ],
      ),
      body: reportProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mensagem de sucesso
                  if (reportProvider.successMessage != null) ...[
                    _buildSuccessCard(
                      reportProvider.successMessage!,
                      () => reportProvider.clearSuccess(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Mensagem de erro
                  if (reportProvider.errorMessage != null) ...[
                    _buildErrorCard(
                      reportProvider.errorMessage!,
                      () => reportProvider.clearError(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Filtros
                  const ReportFilters(),
                  const SizedBox(height: 16),

                  // StoryPoints Estimation Card
                  const StoryPointsEstimationCard(),
                  const SizedBox(height: 16),

                  // Botão de gerar relatório
                  ElevatedButton.icon(
                    onPressed: () => reportProvider.generateReport(),
                    icon: const Icon(Icons.search),
                    label: const Text('Gerar Relatório'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas
                  if (reportProvider.tasks.isNotEmpty) ...[
                    const StatisticsCards(),
                    const SizedBox(height: 24),

                    // Botões de exportação rápida
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportTasks(context),
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Exportar Tarefas'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _exportStatistics(context),
                            icon: const Icon(Icons.analytics),
                            label: const Text('Exportar Estatísticas'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tabela de tarefas
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tarefas (${reportProvider.tasks.length})',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Chip(
                                  label: Text(
                                    '${reportProvider.statistics['completionRate']}% concluído',
                                  ),
                                  backgroundColor: Colors.green.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const TasksTable(),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Mensagem quando não há dados
                  if (reportProvider.tasks.isEmpty &&
                      reportProvider.errorMessage == null &&
                      reportProvider.successMessage == null) ...[
                    const SizedBox(height: 48),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assessment_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum relatório gerado',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecione os filtros acima e clique em "Gerar Relatório"',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSuccessCard(String message, VoidCallback onDismiss) {
    return Card(
      color: Colors.green.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sucesso!',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(color: Colors.green.shade700)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, VoidCallback onDismiss) {
    return Card(
      color: Colors.red.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erro',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(color: Colors.red.shade700)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
              color: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportTasks(BuildContext context) async {
    final reportProvider = context.read<ReportProvider>();

    // Mostrar diálogo de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exportando tarefas...'),
            SizedBox(height: 8),
            Text(
              'O arquivo será salvo e compartilhado',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final filePath = await reportProvider.exportToCSV();

    if (context.mounted) {
      Navigator.of(context).pop(); // Fechar loading

      if (filePath != null) {
        // Sucesso - a mensagem já foi definida no provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Tarefas exportadas com sucesso!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Erro - a mensagem já foi definida no provider
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao exportar tarefas'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _exportStatistics(BuildContext context) async {
    final reportProvider = context.read<ReportProvider>();

    // Mostrar diálogo de loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Exportando estatísticas...'),
            SizedBox(height: 8),
            Text(
              'O arquivo será salvo e compartilhado',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final filePath = await reportProvider.exportStatistics();

    if (context.mounted) {
      Navigator.of(context).pop(); // Fechar loading

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Estatísticas exportadas com sucesso!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao exportar estatísticas'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
