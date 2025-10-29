import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/services/firestore_service.dart';

class KanbanProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _tasksSubscription;

  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  List<Task> get todoTasks =>
      _tasks.where((task) => task.taskStatus == 'To Do').toList();
  List<Task> get doingTasks =>
      _tasks.where((task) => task.taskStatus == 'Doing').toList();
  List<Task> get doneTasks =>
      _tasks.where((task) => task.taskStatus == 'Done').toList();
  bool get isLoading => _isLoading;

  KanbanProvider(this._firestoreService) {
    _tasksSubscription = _firestoreService.getTasksStream().listen((tasksData) {
      _tasks = tasksData;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> moveTask(String taskId, String newStatus) async {
    //TODO: Add business rules here
    //e.g. developer only can move his own tasks? he only can have 2 tasks in Doing?
    await _firestoreService.updateTaskState(taskId, newStatus);
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
