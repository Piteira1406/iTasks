import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/models/task_model.dart';

class TaskDetailsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // Estado para os campos do formulário
  String _description = '';
  int _storyPoints = 0;
  int _executionOrder = 0;
  int? _selectedDeveloperId;
  int? _selectedTaskTypeId;
  DateTime _plannedStartDate = DateTime.now();
  DateTime _plannedEndDate = DateTime.now().add(Duration(days: 1));

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskDetailsProvider(this._firestoreService);

  // Setters para a UI atualizar o estado
  void setDescription(String desc) => _description = desc;
  void setStoryPoints(int points) => _storyPoints = points;
  void setExecutionOrder(int order) => _executionOrder = order;
  void setDeveloperId(int id) => _selectedDeveloperId = id;
  void setTaskTypeId(int id) => _selectedTaskTypeId = id;
  void setPlannedStartDate(DateTime date) => _plannedStartDate = date;
  void setPlannedEndDate(DateTime date) => _plannedEndDate = date;

  Future<bool> saveTask(int managerId, {String? Function(String)? errorCallback}) async {
    _isLoading = true;
    notifyListeners();

    // Validation 1: Required fields
    if (_description.isEmpty) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) errorCallback('Descrição é obrigatória');
      return false;
    }

    if (_selectedDeveloperId == null || _selectedTaskTypeId == null) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) errorCallback('Selecione Programador e Tipo de Tarefa');
      return false;
    }

    if (_storyPoints <= 0) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) errorCallback('Story Points deve ser maior que 0');
      return false;
    }

    if (_executionOrder <= 0) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) errorCallback('Ordem de execução deve ser maior que 0');
      return false;
    }

    if (_plannedEndDate.isBefore(_plannedStartDate)) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) errorCallback('Data de fim deve ser posterior à data de início');
      return false;
    }

    // Validation 2: Check duplicate order for same developer (CRITICAL)
    final canCreate = await _firestoreService.canCreateTaskWithOrder(
      developerId: _selectedDeveloperId!,
      order: _executionOrder,
    );

    if (!canCreate) {
      _isLoading = false;
      notifyListeners();
      if (errorCallback != null) {
        errorCallback(
          'Erro: Já existe uma tarefa com ordem $_executionOrder para este programador. '
          'Escolha outra ordem de execução.'
        );
      }
      return false;
    }

    final newTask = Task(
      id: '', // Firestore irá gerar
      description: _description,
      storyPoints: _storyPoints,
      order: _executionOrder,
      taskStatus: 'ToDo', // Tarefas começam sempre em 'ToDo'
      idManager: managerId,
      idDeveloper: _selectedDeveloperId!,
      idTaskType: _selectedTaskTypeId!,
      creationDate: DateTime.now(),
      previsionStartDate: _plannedStartDate,
      previsionEndDate: _plannedEndDate,
      realStartDate: null,
      realEndDate: null,
    );

    try {
      await _firestoreService.createTask(newTask);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      LoggerService.error('Error saving task', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
