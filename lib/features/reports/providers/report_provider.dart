import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/csv_service.dart';
import 'package:itasks/core/models/task_model.dart';

class ReportProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final CsvService _csvService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Listas para os diferentes relatórios
  final List<Task> _completedTasksManager = [];
  final List<Task> _ongoingTasksManager = [];
  final List<Task> _completedTasksDeveloper = [];

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
    // 1. Buscar tarefas 'ToDo' do gestor
    // 2. Buscar tarefas 'Done' para calcular médias por StoryPoints
    // 3. Aplicar o cálculo
    return "Calculando...";
  }

  Future<void> exportCompletedTasksToCsv(String managerId) async {
    // 1. Buscar os dados das tarefas concluídas
    if (_completedTasksManager.isEmpty) {
      await fetchManagerReports(managerId);
    }

    // 2. BUSCAR DADOS RELACIONADOS (TODO: implementar no FirestoreService)
    // List<AppUser> allDevelopers = await _firestoreService.getAllDevelopers();
    // List<TaskType> allTaskTypes = await _firestoreService.getAllTaskTypes();

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
      // Lógica para encontrar nomes a partir dos IDs
      // String developerName = allDevelopers.firstWhere((d) => d.id == task.idDeveloper, orElse: () => null)?.name ?? 'N/A';
      // String taskTypeName = allTaskTypes.firstWhere((t) => t.id == task.idTaskType, orElse: () => null)?.name ?? 'N/A';

      // Lógica de cálculo de datas
      final plannedDays = task.previsionEndDate
          .toDate()
          .difference(task.previsionStartDate.toDate())
          .inDays;

      // Verifica se as datas reais são válidas (não são placeholders)
      final hasRealDates =
          task.realStartDate.toDate().year > 1970 &&
          task.realEndDate.toDate().year > 1970;
      final realDays = hasRealDates
          ? task.realEndDate
                .toDate()
                .difference(task.realStartDate.toDate())
                .inDays
          : 0;

      rows.add([
        task.description,
        // developerName, // Usar o nome quando implementar
        // taskTypeName, // Usar o nome quando implementar
        task.idDeveloper, // Temporário: mostrar ID até implementar busca de nomes
        task.idTaskType, // Temporário: mostrar ID até implementar busca de nomes
        task.previsionStartDate.toDate().toLocal().toString().split(
          ' ',
        )[0], // Formatar data
        task.previsionEndDate.toDate().toLocal().toString().split(' ')[0],
        hasRealDates
            ? task.realStartDate.toDate().toLocal().toString().split(' ')[0]
            : 'N/A',
        hasRealDates
            ? task.realEndDate.toDate().toLocal().toString().split(' ')[0]
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
