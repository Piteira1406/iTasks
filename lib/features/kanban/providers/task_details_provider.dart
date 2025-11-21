import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/task_type_model.dart';

class TaskDetailsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- Listas para os Dropdowns ---
  List<AppUser> _developersList = [];

  // CORREÇÃO: Agora é uma Lista de TaskType, não dynamic
  List<TaskTypeModel> _taskTypesList = [];

  List<AppUser> get developersList => _developersList;

  // CORREÇÃO: O getter também devolve List<TaskType>
  List<TaskTypeModel> get taskTypesList => _taskTypesList;

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
  
  DateTime get plannedStartDate => _plannedStartDate;
  DateTime get plannedEndDate => _plannedEndDate;

  // Dados originais da task (para preservar ao editar)
  String? _originalTaskStatus;
  DateTime? _originalCreationDate;
  DateTime? _originalRealStartDate;
  DateTime? _originalRealEndDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskDetailsProvider(this._firestoreService);

  // --- 1. Carregar Listas (Dropdowns) ---
  Future<void> loadDropdownData() async {
    try {
      // Buscar utilizadores que são 'Developer'
      final allUsers = await _firestoreService.getUsers();
      _developersList = allUsers.where((u) => u.type == 'Developer').toList();

      // Buscar Tipos de Tarefa REAIS da BD
      _taskTypesList = await _firestoreService.getTaskTypes();

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
    
    // Guardar dados originais para preservar ao salvar
    _originalTaskStatus = task.taskStatus;
    _originalCreationDate = task.creationDate;
    _originalRealStartDate = task.realStartDate;
    _originalRealEndDate = task.realEndDate;
    
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
    
    // Limpar dados originais
    _originalTaskStatus = null;
    _originalCreationDate = null;
    _originalRealStartDate = null;
    _originalRealEndDate = null;
    
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

  void setPlannedStartDate(DateTime val) {
    _plannedStartDate = val;
    notifyListeners();
  }

  void setPlannedEndDate(DateTime val) {
    _plannedEndDate = val;
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
      taskStatus: _originalTaskStatus ?? 'ToDo', // Preserva status original ou usa 'ToDo' para novas
      idManager: int.parse(managerId),
      idDeveloper: _selectedDeveloperId!,
      idTaskType: _selectedTaskTypeId!,
      creationDate: _originalCreationDate ?? DateTime.now(), // Preserva data criação
      previsionStartDate: _plannedStartDate,
      previsionEndDate: _plannedEndDate,
      realStartDate: _originalRealStartDate, // Preserva data real início
      realEndDate: _originalRealEndDate, // Preserva data real fim
    );

    try {
      if (existingTaskId == null) {
        await _firestoreService.createTask(taskToSave);
      } else {
        await _firestoreService.updateTask(taskToSave);
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
