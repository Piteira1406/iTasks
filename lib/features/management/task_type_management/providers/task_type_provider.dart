import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_type_model.dart';
import 'package:itasks/core/services/firestore_service.dart';

enum TaskTypeState { idle, loading, error }

class TaskTypeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  TaskTypeProvider(this._firestoreService);

  TaskTypeState _state = TaskTypeState.idle;
  TaskTypeState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<TaskTypeModel> _taskTypesList = [];
  List<TaskTypeModel> get taskTypes => _taskTypesList;

  // 1. Buscar dados (AGORA USA O STREAM)
  Future<void> fetchTaskTypes() async {
    _setState(TaskTypeState.loading);

    try {
      // 2. Em vez de .listen(), usamos 'await' para esperar pela resposta
      // Nota: Não precisas da variável '_taskTypeSubscription' aqui
      final data = await _firestoreService.getTaskTypes();

      _taskTypesList = data; // Guarda os dados
      _setState(TaskTypeState.idle); // Tira o loading
    } catch (e) {
      _setError(e.toString());
    }
  }

  // 2. Adicionar/Atualizar dados
  Future<bool> saveTaskType({
    TaskTypeModel? existingTaskType,
    required String name,
  }) async {
    _setState(TaskTypeState.loading);
    try {
      if (existingTaskType == null) {
        final int newId = await _firestoreService.getNextTaskTypeId();
        final newTask = TaskTypeModel(id: newId, name: name);
        // Chama o método correto do serviço
        await _firestoreService.createTaskType(newTask);
      } else {
        // --- Atualizar Existente ---
        // Usa o 'copyWith' que adicionámos
        final updatedTask = existingTaskType.copyWith(name: name);
        // Chama o método correto do serviço
        await _firestoreService.updateTaskType(updatedTask);
      }

      // Não precisamos chamar fetchTaskTypes() porque o Stream faz isso por nós
      _setState(TaskTypeState.idle);
      return true; // Sucesso
    } catch (e) {
      _setError(e.toString());
      return false; // Falha
    }
  }

  // 3. Apagar dados
  Future<void> deleteTaskType(TaskTypeModel taskType) async {
    _setState(TaskTypeState.loading);
    try {
      // Usa o docId se disponível, senão usa o id convertido para string
      final docIdToDelete = taskType.docId ?? taskType.id.toString();
      
      await _firestoreService.deleteTaskType(docIdToDelete);
      
      _setState(TaskTypeState.idle);
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-lança o erro para o UI poder mostrar
    }
  }

  void _setState(TaskTypeState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = TaskTypeState.error;
    notifyListeners();
  }
}
