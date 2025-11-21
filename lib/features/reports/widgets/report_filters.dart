import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';

class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tipo de relatório
            DropdownButtonFormField<ReportType>(
              value: reportProvider.selectedReportType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Relatório',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.analytics),
              ),
              items: const [
                DropdownMenuItem(
                  value: ReportType.completedTasksByManager,
                  child: Text('Tarefas Concluídas por Gestor'),
                ),
                DropdownMenuItem(
                  value: ReportType.completedTasksByDeveloper,
                  child: Text('Tarefas Concluídas por Programador'),
                ),
                DropdownMenuItem(
                  value: ReportType.ongoingTasks,
                  child: Text('Tarefas em Andamento'),
                ),
                DropdownMenuItem(
                  value: ReportType.allTasks,
                  child: Text('Todas as Tarefas'),
                ),
                DropdownMenuItem(
                  value: ReportType.tasksByStatus,
                  child: Text('Tarefas por Status'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  reportProvider.setReportType(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Filtro por Gestor
            if (reportProvider.selectedReportType == ReportType.completedTasksByManager ||
                reportProvider.selectedReportType == ReportType.ongoingTasks) ...[
              DropdownButtonFormField<int>(
                value: reportProvider.selectedManagerId,
                decoration: const InputDecoration(
                  labelText: 'Gestor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Selecione um gestor'),
                  ),
                  ...reportProvider.managers.map((manager) {
                    return DropdownMenuItem(
                      value: manager.id,
                      child: Text(manager.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) => reportProvider.setSelectedManager(value),
              ),
              const SizedBox(height: 16),
            ],

            // Filtro por Programador
            if (reportProvider.selectedReportType == ReportType.completedTasksByDeveloper) ...[
              DropdownButtonFormField<int>(
                value: reportProvider.selectedDeveloperId,
                decoration: const InputDecoration(
                  labelText: 'Programador',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Selecione um programador'),
                  ),
                  ...reportProvider.developers.map((dev) {
                    return DropdownMenuItem(
                      value: dev.id,
                      child: Text(dev.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) => reportProvider.setSelectedDeveloper(value),
              ),
              const SizedBox(height: 16),
            ],

            // Filtro por Status
            if (reportProvider.selectedReportType == ReportType.tasksByStatus) ...[
              DropdownButtonFormField<String>(
                value: reportProvider.selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Selecione um status')),
                  DropdownMenuItem(value: 'ToDo', child: Text('A Fazer')),
                  DropdownMenuItem(value: 'Doing', child: Text('Em Progresso')),
                  DropdownMenuItem(value: 'Done', child: Text('Concluído')),
                ],
                onChanged: (value) => reportProvider.setSelectedStatus(value),
              ),
              const SizedBox(height: 16),
            ],

            // Filtros de data
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Filtro por Data de Criação (Opcional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DatePickerField(
                    label: 'Data Início',
                    selectedDate: reportProvider.startDate,
                    onDateSelected: (date) {
                      reportProvider.setDateRange(date, reportProvider.endDate);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DatePickerField(
                    label: 'Data Fim',
                    selectedDate: reportProvider.endDate,
                    onDateSelected: (date) {
                      reportProvider.setDateRange(reportProvider.startDate, date);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;

  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onDateSelected(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: selectedDate != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onDateSelected(null),
                )
              : null,
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
              : 'Selecionar data',
          style: TextStyle(
            color: selectedDate != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }
}