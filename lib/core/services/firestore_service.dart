// lib/core/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/task_model.dart'; // <-- Corrigido para TaskModel
import 'package:itasks/core/models/task_type_model.dart';

// ADICIONADO: Padronização dos nomes das coleções
const String usersCollection = 'Users';
const String managersCollection = 'Managers';
const String developersCollection = 'Developers';
const String tasksCollection = 'Tasks';
const String taskTypesCollection = 'TaskTypes';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- USERS ---

  Future<void> createUtilizador(AppUser user, String uid) async {
    await _db.collection(usersCollection).doc(uid).set(user.toMap());
  }

  Future<void> createManager(Manager manager) async {
    await _db.collection(managersCollection).add(manager.toMap());
  }

  Future<void> createDeveloper(Developer developer) async {
    await _db.collection(developersCollection).add(developer.toMap());
  }

  Future<AppUser?> getUtilizadorById(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  // --- MÉTODOS ADICIONADOS (CRÍTICOS PARA O PROJETO) ---

  /// Verifica se um username já existe na coleção 'Users'
  Future<bool> isUsernameUnique(String username) async {
    // CORRIGIDO: O '.get()' estava mal posicionado e a variável 'query'
    // não continha o QuerySnapshot.

    // A forma correta:
    final querySnapshot = await _db
        .collection(usersCollection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get(); // O '.get()' tem de estar aqui, ligado à consulta.

    // Agora 'querySnapshot' é o resultado, e podemos verificar os 'docs'.
    return querySnapshot.docs.isEmpty;
  }

  /// Obtém o perfil de Manager usando o ID do Utilizador (Auth UID)
  Future<Manager?> getManagerByUserId(String uid) async {
    final query = await _db
        .collection(managersCollection)
        .where('idUser', isEqualTo: uid) // Procura pelo campo 'idUser'
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Manager.fromFirestore(query.docs.first);
    }
    return null;
  }

  /// Obtém o perfil de Developer usando o ID do Utilizador (Auth UID)
  Future<Developer?> getDeveloperByUserId(String uid) async {
    final query = await _db
        .collection(developersCollection)
        .where('idUser', isEqualTo: uid) // Procura pelo campo 'idUser'
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Developer.fromFirestore(query.docs.first);
    }
    return null;
  }

  //TODO: Add here methods Update and delete for users (like the business rule of manager)

  // --- TASKS ---

  Future<void> createTask(Task task) async {
    await _db.collection(tasksCollection).add(task.toMap());
  }

  Stream<List<Task>> getTasksStream() {
    return _db.collection(tasksCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateTaskState(String taskId, String newState) async {
    await _db.collection(tasksCollection).doc(taskId).update({
      'taskStatus': newState,
      if (newState == 'Doing') 'realStartDate': Timestamp.now(),
      if (newState == 'Done') 'realEndDate': Timestamp.now(),
    });
  }

  //TODO: Add here methods for getting tasks by developer, by manager, by status, etc.

  // --- TASK TYPES ---
  Future<void> createTaskType(TaskType taskType) async {
    await _db.collection(taskTypesCollection).add(taskType.toMap());
  }

  Stream<List<TaskType>> getTaskTypesStream() {
    return _db.collection(taskTypesCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskType.fromFirestore(doc)).toList();
    });
  }

  // --- MÉTODO 'updateTaskType' ADICIONADO ---
  // (Corrige o erro 'updateTaskTypeModel isn't defined')
  Future<void> updateTaskType(TaskTypeModel taskType) async {
    // Usa o ID do modelo para saber qual documento atualizar
    await _db.collection('TaskType').doc(taskType.id).update(taskType.toMap());
  }

  // --- MÉTODO 'deleteTaskType' ADICIONADO ---
  Future<void> deleteTaskType(String taskTypeId) async {
    await _db.collection('TaskType').doc(taskTypeId).delete();
  }
}
