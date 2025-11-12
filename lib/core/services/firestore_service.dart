import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/task_type_model.dart'; // <-- O NOME DA CLASSE AQUI DENTRO É 'TaskType'

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

  Future<bool> isUsernameUnique(String username) async {
    final querySnapshot = await _db
        .collection(usersCollection)
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<Manager?> getManagerByUserId(String uid) async {
    final query = await _db
        .collection(managersCollection)
        .where('idUser', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Manager.fromFirestore(query.docs.first);
    }
    return null;
  }

  Future<Developer?> getDeveloperByUserId(String uid) async {
    final query = await _db
        .collection(developersCollection)
        .where('idUser', isEqualTo: uid)
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

  Future<void> createTaskType(TaskTypeModel taskType) async {
    await _db.collection(taskTypesCollection).add(taskType.toMap());
  }

  Stream<List<TaskTypeModel>> getTaskTypesStream() {
    // <-- CORRIGIDO: de 'TaskTypeModel' para 'TaskType'
    return _db.collection(taskTypesCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskTypeModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> updateTaskType(TaskTypeModel taskType) async {
    // Usa o ID do modelo para saber qual documento atualizar
    await _db
        .collection(
          taskTypesCollection,
        ) // <-- CORRIGIDO: de 'TaskType' para a constante
        .doc(taskType.id)
        .update(taskType.toMap());
  }

  Future<void> deleteTaskType(String taskTypeId) async {
    await _db
        .collection(
          taskTypesCollection,
        ) // <-- CORRIGIDO: de 'TaskType' para a constante
        .doc(taskTypeId)
        .delete();
  }
}
