// lib/features/kanban/providers/kanban_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart'; // <-- Usa a classe 'Task'
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/providers/auth_provider.dart'; // <-- Importa o AuthProvider

class KanbanProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthProvider _authProvider; // <-- 1. Para as regras de negócio
  StreamSubscription? _tasksSubscription;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // --- Getters para as colunas (já ordenados) ---
  List<Task> get todoTasks => _getSortedList('ToDo');
  List<Task> get doingTasks => _getSortedList('Doing');
  List<Task> get doneTasks => _getSortedList('Done');

  List<Task> _getSortedList(String status) {
    var list = _tasks.where((task) => task.taskStatus == status).toList();
    // Ordena pela propriedade 'order'
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  KanbanProvider(
    this._firestoreService,
    this._authProvider,
  ); // <-- 2. Recebe o AuthProvider

  void fetchTasks() {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    _tasksSubscription?.cancel();
    _tasksSubscription = _firestoreService.getTasksStream().listen(
      (tasksData) {
        _tasks = tasksData;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = "Erro ao carregar tarefas: $error";
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // --- 3. NOVA FUNÇÃO ÚNICA PARA DRAG-AND-DROP ---
  Future<void> handleTaskMove(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) async {
    // 1. Descobrir qual a tarefa e as listas
    // Mapeamento dos índices: 0=ToDo, 1=Doing, 2=Done
    final List<String> listMap = ['ToDo', 'Doing', 'Done'];
    final String oldStatus = listMap[oldListIndex];
    final String newStatus = listMap[newListIndex];

    // Encontra a tarefa que foi movida
    final Task task = _getSortedList(oldStatus)[oldItemIndex];

    // --- 4. REGRAS DE NEGÓCIO (DO ENUNCIADO) ---
    final String currentUserId = _authProvider.appUser?.id ?? '';

    // Regra: Programador só pode mover as suas próprias tarefas
    if (_authProvider.appUser?.type == 'Programador') {
      if (task.idDeveloper != currentUserId) {
        _setError("Erro: Só pode mover tarefas que lhe estão atribuídas.");
        return; // Cancela a operação
      }
    }

    // Regra: Programador só pode ter 2 tarefas em "Doing"
    // (Apenas se estiver a mover para "Doing", não a reordenar)
    if (oldStatus != 'Doing' &&
        newStatus == 'Doing' &&
        _authProvider.appUser?.type == 'Programador') {
      final doingTasksForThisDev = doingTasks
          .where((t) => t.idDeveloper == currentUserId)
          .length;
      if (doingTasksForThisDev >= 2) {
        _setError("Erro: Só pode ter 2 tarefas em 'Doing' em simultâneo.");
        return; // Cancela a operação
      }
    }

    // Regra: Tarefas "Done" não podem ser movidas
    if (oldStatus == 'Done') {
      _setError("Erro: Tarefas concluídas não podem ser movidas.");
      return; // Cancela a operação
    }

    // Regra: Programador tem de seguir a OrdemDeExecucao
    if (_authProvider.appUser?.type == 'Programador') {
      // Se está a tentar mover algo para 'Doing' ou 'Done'
      if (newStatus == 'Doing' || newStatus == 'Done') {
        // Verifique se existem tarefas com 'order' mais baixa em 'ToDo'
        final pendingTasks = todoTasks.where(
          (t) => t.idDeveloper == currentUserId && t.order < task.order,
        );
        if (pendingTasks.isNotEmpty) {
          _setError(
            "Erro: Tem de concluir a tarefa '${pendingTasks.first.description}' primeiro.",
          );
          return;
        }
      }
      // Se está a tentar mover algo para 'Done'
      if (newStatus == 'Done') {
        // Verifique se existem tarefas com 'order' mais baixa em 'Doing'
        final doingTasksList = doingTasks.where(
          (t) => t.idDeveloper == currentUserId && t.order < task.order,
        );
        if (doingTasksList.isNotEmpty) {
          _setError(
            "Erro: Tem de concluir a tarefa '${doingTasksList.first.description}' primeiro.",
          );
          return;
        }
      }
    }

    _setError(''); // Limpa erros antigos

    // 5. ATUALIZAÇÃO DA UI (OTIMISTA)
    // Atualiza o objeto na lista principal (esta é a forma correta)
    final taskIndexInMainList = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndexInMainList != -1) {
      _tasks[taskIndexInMainList] = task.copyWith(taskStatus: newStatus);
    }
    notifyListeners(); // Avisa a UI

    // 6. ATUALIZAÇÃO DA DB (EM SEGUNDO PLANO)
    try {
      await _firestoreService.updateTaskState(task.id, newStatus);
      // TODO: Reordenar (atualizar a 'order') no Firestore
      // ... (lógica de reorderTask)
    } catch (e) {
      _setError("Erro ao salvar: $e");
      fetchTasks(); // Reverte
    }
  }

  // Helper para mostrar erros temporários
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
    // Limpa o erro depois de 3 segundos
    Timer(Duration(seconds: 3), () {
      if (_errorMessage == message) {
        _errorMessage = '';
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
