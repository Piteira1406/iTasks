// lib/features/reports/providers/report_provider.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/csv_service.dart';
import 'package:itasks/core/models/task_model.dart'; // <-- O modelo chama-se TaskModel

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final CsvService _csvService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Task> _completedTasksManager = [];
  List<Task> _ongoingTasksManager = [];
  List<Task> _completedTasksDeveloper = [];

  List<Task> get completedTasksManager => _completedTasksManager;
  List<Task> get ongoingTasksManager => _ongoingTasksManager;
  List<Task> get completedTasksDeveloper => _completedTasksDeveloper;

  ReportProvider(this._firestoreService, this._csvService);

  Future<void> fetchManagerReports(String managerId) async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implementar no FirestoreService
    // _completedTasksManager = await _firestoreService.getCompletedTasksForManager(managerId);
    // _ongoingTasksManager = await _firestoreService.getOngoingTasksForManager(managerId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDeveloperReports(String developerId) async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implementar no FirestoreService
    // _completedTasksDeveloper = await _firestoreService.getCompletedTasksForDeveloper(developerId);
    _isLoading = false;
    notifyListeners();
  }

  Future<String> getTodoTimeEstimate(String managerId) async {
    // TODO: Implementar o algoritmo de estimativa
    // ...
    return "Calculando...";
  }

  Future<void> exportCompletedTasksToCsv(String managerId) async {
    // 1. Buscar os dados das tarefas concluídas
    if (_completedTasksManager.isEmpty) {
      await fetchManagerReports(managerId);
    }

    // 2. BUSCAR DADOS RELACIONADOS (TODO: implementar)
    // ...

    // 3. Formatar os dados para a lista de listas
    List<List<dynamic>> rows = [];

    // 3.1. Adicionar Cabeçalhos
    rows.add([
      "Description",
      "Developer", // Nome, não ID
      "TaskType", // Nome, não ID
      "Planned Start Date",
      "Planned End Date",
      "Real Start Date",
      "Real End Date",
      "Planned Time (days)",
      "Real Time (days)",
    ]);

    // 3.2. Adicionar dados de cada tarefa
    for (var task in _completedTasksManager) {
      // ... (lógica para buscar nomes)

      // Lógica de cálculo de datas
      // <-- CORRIGIDO: Removido .toDate()
      final plannedDays =
          task.previsionEndDate.difference(task.previsionStartDate).inDays +
          1; // +1 para incluir o dia de início

      // <-- CORRIGIDO: Datas reais podem ser nulas
      final hasRealDates =
          task.realStartDate != null && task.realEndDate != null;

      final realDays = hasRealDates
          ? task
                    .realEndDate! // <-- Usa ! porque verificámos o null
                    .difference(task.realStartDate!) // <-- Usa !
                    .inDays +
                1 // +1
          : 0;

      rows.add([
        task.description,
        task.idDeveloper, // Temporário
        task.idTaskType, // Temporário
        // <-- CORRIGIDO: Removido .toDate()
        task.previsionStartDate.toLocal().toString().split(' ')[0],
        task.previsionEndDate.toLocal().toString().split(' ')[0],

        // <-- CORRIGIDO: Removido .toDate() e adicionado !
        hasRealDates
            ? task.realStartDate!.toLocal().toString().split(' ')[0]
            : 'N/A',
        hasRealDates
            ? task.realEndDate!.toLocal().toString().split(' ')[0]
            : 'N/A',

        plannedDays,
        realDays,
      ]);
    }

    // 4. Chamar o CsvService
    try {
      await _csvService.generateAndShareCsv(rows, "Report_Completed_Tasks.csv");
    } catch (e) {
      print("Export error: $e");
    }
  }
}
