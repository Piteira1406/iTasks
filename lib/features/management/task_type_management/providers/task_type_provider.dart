import 'dart:async';
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_type_model.dart';
import 'package:itasks/core/services/firestore_service.dart';

class TaskTypeProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription? _taskTypesSubscription;

  List<TaskType> _taskTypes = [];
  bool _isLoading = true;

  List<TaskType> get taskTypes => _taskTypes;
  bool get isLoading => _isLoading;

  TaskTypeProvider(this._firestoreService) {
    // "Ouve" o stream de tipos de tarefa do Firestore
    _taskTypesSubscription = _firestoreService.getTaskTypesStream().listen((
      types,
    ) {
      _taskTypes = types;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createTaskType(String name) async {
    final newType = TaskType(
      id: '',
      name: name,
    ); // ID será gerado pelo Firestore
    await _firestoreService.createTaskType(newType);
    // Não precisa de notifyListeners(), o stream trata disso
  }

  Future<void> updateTaskType(String id, String newName) async {
    // TODO: Implementar 'updateTaskType' no FirestoreService
    // await _firestoreService.updateTaskType(id, newName);
  }

  Future<void> deleteTaskType(String id) async {
    // TODO: Implementar 'deleteTaskType' no FirestoreService
    // await _firestoreService.deleteTaskType(id);
  }

  @override
  void dispose() {
    _taskTypesSubscription?.cancel();
    super.dispose();
  }
}
