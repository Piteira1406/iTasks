import 'package:flutter/material.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/app_user_model.dart'; // <--- Importante
// Certifica-te que tens um model TaskType, ou usa Map se não tiveres
// import 'package:itasks/core/models/task_type_model.dart';

class TaskDetailsProvider with ChangeNotifier {
  final FirestoreService _firestoreService;

  // --- Listas para os Dropdowns ---
  List<AppUser> _developersList = [];
  List<dynamic> _taskTypesList =
      []; // Usa o teu modelo TaskType aqui se tiveres

  List<AppUser> get developersList => _developersList;
  List<dynamic> get taskTypesList => _taskTypesList;

  // --- Estado do Formulário ---
  String _description = '';
  int _storyPoints = 0;
  int _executionOrder = 0;
  String? _selectedDeveloperId;
  String? _selectedTaskTypeId;

  // Getters
  String get description => _description;
  int get storyPoints => _storyPoints;
  String? get selectedDeveloperId => _selectedDeveloperId;
  String? get selectedTaskTypeId => _selectedTaskTypeId;

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
      // Nota: O firestoreService precisa de ter um método getAllUsers ou similar
      final allUsers = await _firestoreService.getUsers();
      _developersList = allUsers.where((u) => u.type == 'Programador').toList();

      // Buscar Tipos de Tarefa
      // Se ainda não tiveres o metodo getTaskTypes, cria no FirestoreService
      // _taskTypesList = await _firestoreService.getTaskTypes();

      // MOCK (Temporário enquanto não tens TaskTypes na DB):
      _taskTypesList = [
        {'id': 'bug', 'name': 'Bug Fix'},
        {'id': 'feature', 'name': 'Nova Feature'},
        {'id': 'melhoria', 'name': 'Melhoria'},
      ];

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

  void setDeveloperId(String? val) {
    _selectedDeveloperId = val;
    notifyListeners();
  }

  void setTaskTypeId(String? val) {
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
      id: existingTaskId ?? '', // Se for null, o Firestore cria ID novo
      description: _description,
      storyPoints: _storyPoints,
      order: _executionOrder,
      taskStatus: 'ToDo',
      idManager: managerId,
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
        // await _firestoreService.updateTask(taskToSave); // Precisas criar este método se não existir
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
