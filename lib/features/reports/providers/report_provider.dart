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
    // 1. Buscar tarefas 'ToDo' do gestor
    // 2. Buscar tarefas 'Done' para calcular médias por StoryPoints
    // 3. Aplicar o cálculo
    return "Calculando...";
  }

  Future<void> exportCompletedTasksToCsv(String managerId) async {
    // 1. Buscar os dados (se ainda não os tiver)
    if (_completedTasksManager.isEmpty) {
      await fetchManagerReports(managerId);
    }

    // 2. TODO: Buscar dados relacionados (Nome do Developer, Nome do TaskType)
    // O CSVService precisará dos nomes, não dos IDs

    // 3. Passar os dados formatados para o CsvService
    // await _csvService.generateManagerCsv(_completedTasksManager);
  }
}
