import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/app_user_model.dart';

class TaskDetailsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- Listas para os Dropdowns ---
  List<AppUser> _developersList = [];

  // CORREÇÃO: Agora é uma Lista de TaskType, não dynamic
  List<Task> _taskTypesList = [];

  List<AppUser> get developersList => _developersList;

  // CORREÇÃO: O getter também devolve List<TaskType>
  List<Task> get taskTypesList => _taskTypesList;

  // --- Estado do Formulário ---
  String _description = '';
  int _storyPoints = 0;
  int _executionOrder = 0;
  int? _selectedDeveloperId;
  int? _selectedTaskTypeId;

  // Getters
  String get description => _description;
  int get storyPoints => _storyPoints;
  int? get selectedDeveloperId => _selectedDeveloperId;
  int? get selectedTaskTypeId => _selectedTaskTypeId;

  // Datas
  DateTime _plannedStartDate = DateTime.now();
  DateTime _plannedEndDate = DateTime.now().add(const Duration(days: 1));

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskDetailsProvider(this._firestoreService);

  // --- 1. Carregar Listas (Dropdowns) ---
  Future<void> loadDropdownData() async {
    try {
      // Buscar utilizadores que são 'Programador'
      final allUsers = await _firestoreService.getUsers();
      _developersList = allUsers.where((u) => u.type == 'Programador').toList();

      // Buscar Tipos de Tarefa REAIS da BD
      // O teu FirestoreService já deve ter este método a devolver List<TaskType>
      _taskTypesList = await _firestoreService.getTask();

      notifyListeners();
    } catch (e) {
      LoggerService.error('Erro ao carregar dropdowns', e);
    }
  }

  // --- 2. Preencher formulário (Modo Edição) ---
  void setTaskData(Task task) {
    _description = task.description;
    _storyPoints = task.storyPoints;
    _executionOrder = task.order;
    _selectedDeveloperId = task.idDeveloper;
    _selectedTaskTypeId = task.idTaskType;
    _plannedStartDate = task.previsionStartDate;
    _plannedEndDate = task.previsionEndDate;
    notifyListeners();
  }

  // --- 3. Limpar formulário (Modo Criação) ---
  void clearForm() {
    _description = '';
    _storyPoints = 0;
    _executionOrder = 0;
    _selectedDeveloperId = null;
    _selectedTaskTypeId = null;
    _plannedStartDate = DateTime.now();
    _plannedEndDate = DateTime.now().add(const Duration(days: 1));
    notifyListeners();
  }

  // Setters simples
  void setDescription(String val) {
    _description = val;
    notifyListeners();
  }

  void setStoryPoints(int val) {
    _storyPoints = val;
    notifyListeners();
  }

  void setDeveloperId(int? val) {
    _selectedDeveloperId = val;
    notifyListeners();
  }

  void setTaskTypeId(int? val) {
    _selectedTaskTypeId = val;
    notifyListeners();
  }

  // --- 4. Salvar ---
  Future<bool> saveTask(String managerId, {String? existingTaskId}) async {
    _isLoading = true;
    notifyListeners();

    if (_selectedDeveloperId == null ||
        _selectedTaskTypeId == null ||
        _description.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final taskToSave = Task(
      id: existingTaskId ?? '',
      description: _description,
      storyPoints: _storyPoints,
      order: _executionOrder,
      taskStatus: 'ToDo',
      idManager: int.parse(managerId),
      idDeveloper: _selectedDeveloperId!,
      idTaskType: _selectedTaskTypeId!,
      creationDate: DateTime.now(),
      previsionStartDate: _plannedStartDate,
      previsionEndDate: _plannedEndDate,
      realStartDate: DateTime(1970),
      realEndDate: DateTime(1970),
    );

    try {
      if (existingTaskId == null) {
        await _firestoreService.createTask(taskToSave);
      } else {
        // TODO: Implementar updateTask se necessário
        // await _firestoreService.updateTask(taskToSave);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      LoggerService.error('Erro ao salvar tarefa', e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
