import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/models/task_model.dart';

class TaskDetailsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // Estado para os campos do formulário
  String _description = '';
  int _storyPoints = 0;
  int _executionOrder = 0;
  String? _selectedDeveloperId;
  String? _selectedTaskTypeId;
  DateTime _plannedStartDate = DateTime.now();
  DateTime _plannedEndDate = DateTime.now().add(Duration(days: 1));

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskDetailsProvider(this._firestoreService);

  // Setters para a UI atualizar o estado
  void setDescription(String desc) => _description = desc;
  void setStoryPoints(int points) => _storyPoints = points;
  void setExecutionOrder(int order) => _executionOrder = order;
  void setDeveloperId(String id) => _selectedDeveloperId = id;
  void setTaskTypeId(String id) => _selectedTaskTypeId = id;
  void setPlannedStartDate(DateTime date) => _plannedStartDate = date;
  void setPlannedEndDate(DateTime date) => _plannedEndDate = date;

  Future<bool> saveTask(String managerId) async {
    _isLoading = true;
    notifyListeners();

    // TODO: Adicionar validação de formulário
    if (_selectedDeveloperId == null || _selectedTaskTypeId == null) {
      _isLoading = false;
      notifyListeners();
      return false; // Falha na validação
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
      creationDate: Timestamp.now(),
      previsionStartDate: Timestamp.fromDate(_plannedStartDate),
      previsionEndDate: Timestamp.fromDate(_plannedEndDate),
      realStartDate: Timestamp.fromDate(
        DateTime(1970),
      ), // Placeholder para Timestamp não-nulo
      realEndDate: Timestamp.fromDate(
        DateTime(1970),
      ), // Placeholder para Timestamp não-nulo
    );

    try {
      await _firestoreService.createTask(newTask);
      _isLoading = false;
      notifyListeners();
      return true; // Sucesso
    } catch (e) {
      print('Error saving task: $e');
      _isLoading = false;
      notifyListeners();
      return false; // Falha
    }
  }

  // TODO: Adicionar método 'loadTaskForEdit(String taskId)'
  // Este método irá buscar uma tarefa ao Firestore e preencher os campos
  // do formulário para edição.
}
