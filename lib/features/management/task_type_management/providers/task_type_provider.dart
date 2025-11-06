// features/management/task_type_management/providers/task_type_provider.dart

import 'dart:async'; // <-- Importa o 'async' para o StreamSubscription
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_type_model.dart';
import 'package:itasks/core/services/firestore_service.dart';

enum TaskTypeState { idle, loading, error }

class TaskTypeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _taskTypeSubscription; // <-- Para "ouvir" o Stream

  TaskTypeProvider(this._firestoreService) {
    // Começa a "ouvir" os dados assim que o provider é criado
    fetchTaskTypes();
  }

  TaskTypeState _state = TaskTypeState.idle;
  TaskTypeState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<TaskTypeModel> _taskTypes = [];
  List<TaskTypeModel> get taskTypes => List.unmodifiable(_taskTypes);

  // 1. Buscar dados (AGORA USA O STREAM)
  void fetchTaskTypes() {
    _setState(TaskTypeState.loading);

    _taskTypeSubscription?.cancel(); // Cancela qualquer 'listener' antigo
    _taskTypeSubscription = _firestoreService.getTaskTypesStream().listen(
      (data) {
        _taskTypes = data; // Atualiza a lista com os dados do stream
        _setState(TaskTypeState.idle);
      },
      onError: (e) {
        _setError(e.toString());
      },
    );
  }

  // 2. Adicionar/Atualizar dados
  Future<bool> saveTaskType({
    TaskTypeModel? existingTaskType,
    required String name,
  }) async {
    _setState(TaskTypeState.loading);
    try {
      if (existingTaskType == null) {
        // --- Criar Novo ---
        final newTask = TaskTypeModel(id: '', name: name);
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
  Future<void> deleteTaskType(String id) async {
    _setState(TaskTypeState.loading);
    try {
      // Chama o método que adicionámos ao serviço
      await _firestoreService.deleteTaskType(id);
      // O Stream vai atualizar a lista automaticamente
      _setState(TaskTypeState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // --- Helpers internos ---
  void _setState(TaskTypeState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = TaskTypeState.error;
    notifyListeners();
  }

  // Limpa o 'listener' do stream quando o provider é destruído
  @override
  void dispose() {
    _taskTypeSubscription?.cancel();
    super.dispose();
  }
}
