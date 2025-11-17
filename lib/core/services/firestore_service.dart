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

  Future<void> createUser(AppUser user, String uid) async {
    await _db.collection(usersCollection).doc(uid).set(user.toMap());
  }

  Future<void> createManager(Manager manager) async {
    await _db.collection(managersCollection).add(manager.toMap());
  }

  Future<void> createDeveloper(Developer developer) async {
    await _db.collection(developersCollection).add(developer.toMap());
  }

  Future<AppUser?> getUserById(String uid) async {
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

  Future<List<Manager>> getManagers() async {
    final querySnapshot = await _db.collection(managersCollection).get();
    return querySnapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();
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

  Future<void> updateTaskOrder(String taskId, int newOrder) async {
    await _db.collection(tasksCollection).doc(taskId).update({
      'order': newOrder,
    });
  }

  Future<List<Task>> getCompletedTasksForManager(String managerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idManager', isEqualTo: managerId)
        .where('taskStatus', isEqualTo: 'Done')
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getOngoingTasksForManager(String managerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idManager', isEqualTo: managerId)
        .where('taskStatus', whereIn: ['ToDo', 'Doing'])
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getCompletedTasksForDeveloper(String developerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .where('taskStatus', isEqualTo: 'Done')
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getTasksByDeveloper(String developerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  // --- USERS ---

  Stream<List<AppUser>> getUsersStream() {
    return _db.collection(usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  Future<List<AppUser>> getUsers() async {
    final querySnapshot = await _db.collection(usersCollection).get();
    return querySnapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }

  Future<void> updateUser(String uid, AppUser user) async {
    await _db.collection(usersCollection).doc(uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(usersCollection).doc(uid).delete();
  }

  Future<void> updateManager(Manager manager) async {
    await _db
        .collection(managersCollection)
        .doc(manager.id.toString())
        .update(manager.toMap());
  }

  Future<void> deleteManager(String managerId) async {
    await _db.collection(managersCollection).doc(managerId).delete();
  }

  Future<void> updateDeveloper(Developer developer) async {
    await _db
        .collection(developersCollection)
        .doc(developer.id.toString())
        .update(developer.toMap());
  }

  Future<void> deleteDeveloper(String developerId) async {
    await _db.collection(developersCollection).doc(developerId).delete();
  }

  // --- TASK TYPES ---

  Future<void> createTaskType(TaskType taskType) async {
    await _db.collection(taskTypesCollection).add(taskType.toMap());
  }

  Future<List<TaskType>> getTaskTypes() async {
    try {
      // Atenção: Verifica se no Firebase a coleção chama-se "TaskTypes" ou "task_types"
      QuerySnapshot snapshot = await _db.collection('TaskTypes').get();

      return snapshot.docs.map((doc) {
        return TaskType.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Erro ao buscar TaskTypes: $e');
      return [];
    }
  }

  Future<void> updateTaskType(TaskType taskType) async {
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
