// lib/features/kanban/providers/kanban_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart'; // <-- Usa o TaskModel real
import 'package:itasks/core/services/firestore_service.dart';

class KanbanProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _tasksSubscription;

  // --- Estado ---
  List<Task> _tasks = []; // <-- Corrigido para TaskModel
  bool _isLoading = true;
  String _errorMessage = ''; // <-- ADICIONADO para corrigir o erro

  // --- Getters ---
  bool get isLoading => _isLoading;
  String get errorMessage =>
      _errorMessage; // <-- ADICIONADO para corrigir o erro

  // Getters para as colunas (usando TaskModel)
  List<Task> get tasks => _tasks;

  List<Task> get todoTasks {
    var list = _tasks.where((task) => task.taskStatus == 'ToDo').toList();
    list.sort((a, b) => a.order.compareTo(b.order)); // Ordena por 'order'
    return list;
  }

  List<Task> get doingTasks {
    var list = _tasks.where((task) => task.taskStatus == 'Doing').toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<Task> get doneTasks {
    var list = _tasks.where((task) => task.taskStatus == 'Done').toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  // --- Construtor ---
  // O construtor agora apenas recebe o serviço
  KanbanProvider(this._firestoreService);

  // --- Métodos ---

  // Método que o KanbanScreen chama para começar a "ouvir"
  void fetchTasks() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _tasksSubscription?.cancel(); // Cancela qualquer subscrição antiga
    _tasksSubscription = _firestoreService.getTasksStream().listen(
      (tasksData) {
        // Sucesso
        _tasks = tasksData;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        // Erro
        _errorMessage = "Erro ao carregar tarefas: $error"; // <-- ADICIONADO
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> moveTask(String taskId, String newStatus) async {
    //TODO: Add business rules here
    //e.g. developer only can move his own tasks? he only can have 2 tasks in Doing?

    // Não usamos copyWith porque Task não define esse método; confiamos no stream da DB para atualizar a UI.
    try {
      final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex != -1) {
        // Evitamos modificar o objeto localmente porque o modelo pode ser imutável.
        // A atualização será refletida quando o stream do Firestore emitir a nova lista.
      }

      // Atualiza a DB - o stream de tarefas deve refletir essa mudança
      await _firestoreService.updateTaskState(taskId, newStatus);
    } catch (e) {
      // Se falhar, reverte e mostra o erro
      _errorMessage = "Erro ao mover tarefa: $e";
      fetchTasks(); // Recarrega tudo da DB para garantir consistência
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
