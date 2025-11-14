import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:itasks/features/reports/providers/report_provider.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/task_type_model.dart';

class TasksTable extends StatelessWidget {
  const TasksTable({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final tasks = reportProvider.tasks;

    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Nenhuma tarefa encontrada'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: MaterialStateProperty.all(
          Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        columns: const [
          DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Story Points', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Programador', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Criação', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Tempo Real', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: tasks.map((task) {
          // Buscar nomes
          final developer = reportProvider.developers.firstWhere(
            (d) => d.id == task.idDeveloper,
            orElse: () => Developer(
              id: task.idDeveloper,
              name: 'ID: ${task.idDeveloper}',
              experienceLevel: '',
              idUser: 0,
              idManager: 0,
            ),
          );

          final taskType = reportProvider.taskTypes.firstWhere(
            (t) => t.id == task.idTaskType,
            orElse: () => TaskTypeModel(
              id: task.idTaskType,
              name: 'ID: ${task.idTaskType}',
            ),
          );

          // Calcular tempo real
          String realTime = 'N/A';
          if (task.realStartDate != null && task.realEndDate != null) {
            final duration = task.realEndDate!.difference(task.realStartDate!);
            final hours = duration.inHours;
            final minutes = duration.inMinutes % 60;
            realTime = '${hours}h ${minutes}m';
          }

          return DataRow(
            cells: [
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    task.description,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(_buildStatusChip(task.taskStatus)),
              DataCell(
                Center(
                  child: Chip(
                    label: Text(task.storyPoints.toString()),
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ),
              DataCell(Text(developer.name)),
              DataCell(Text(taskType.name)),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(task.creationDate))),
              DataCell(Text(realTime)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'ToDo':
        color = Colors.grey;
        label = 'A Fazer';
        break;
      case 'Doing':
        color = Colors.orange;
        label = 'Em Progresso';
        break;
      case 'Done':
        color = Colors.green;
        label = 'Concluído';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}