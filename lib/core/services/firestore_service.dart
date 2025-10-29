import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/task_type_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //USERS

  Future<void> createUtilizador(AppUser user, String uid) async {
    await _db.collection('Utilizador').doc(uid).set(user.toMap());
  }

  Future<void> createManager(Manager manager, String uid) async {
    await _db.collection('Manager').add(manager.toMap());
  }

  Future<void> createDeveloper(Developer developer, String uid) async {
    await _db.collection('Developer').add(developer.toMap());
  }

  Future<AppUser?> getUtilizadorById(String uid) async {
    final doc = await _db.collection('Utilizador').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  //TODO: Add here methods Update and delete for users (like the business rule of manager)

  //TASKS

  Future<void> createTask(Task task) async {
    await _db.collection('Task').add(task.toMap());
  }

  Stream<List<Task>> getTasksStream() {
    return _db.collection('Task').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateTaskState(String taskId, String newState) async {
    await _db.collection('Task').doc(taskId).update({
      'taskStatus': newState,
      if (newState == 'Doing') 'realStartDate': Timestamp.now(),
      if (newState == 'Done') 'realEndDate': Timestamp.now(),
    });
  }

  //TODO: Add here methods for getting tasks by developer, by manager, by status, etc.

  //TASK TYPES
  Future<void> createTaskType(TaskType taskType) async {
    await _db.collection('TaskType').add(taskType.toMap());
  }

  Stream<List<TaskType>> getTaskTypesStream() {
    return _db.collection('TaskType').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TaskType.fromFirestore(doc)).toList();
    });
  }

  //TODO: Add here methods Update and delete for task types.
}
