import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/core/models/task_type_model.dart'; // <-- O NOME DA CLASSE AQUI DENTRO É 'TaskType'
import 'package:itasks/core/services/logger_service.dart';

const String usersCollection = 'Users';
const String managersCollection = 'Managers';
const String developersCollection = 'Developers';
const String tasksCollection = 'Tasks';
const String taskTypesCollection = 'TaskTypes';
const String countersCollection = 'Counters';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getNextUserId() async {
    return await _getNextId('userId');
  }

  Future<int> getNextManagerId() async {
    return await _getNextId('managerId');
  }

  Future<int> getNextDeveloperId() async {
    return await _getNextId('developerId');
  }

  Future<int> getNextTaskTypeId() async {
    return await _getNextId('taskTypeId');
  }

  Future<int> _getNextId(String counterName) async {
    final counterRef = _db.collection(countersCollection).doc(counterName);

    int nextId = 1;
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        transaction.set(counterRef, {'value': nextId});
      } else {
        final currentValue = snapshot.data()?['value'] ?? 0;
        nextId = currentValue + 1;
        transaction.update(counterRef, {'value': nextId});
      }
    });

    return nextId;
  }

  // --- USERS ---

  Future<void> createUser(AppUser user, String uid) async {
    await _db.collection(usersCollection).doc(uid).set(user.toMap());
  }

  Future<void> createManager(Manager manager) async {
    await _db
        .collection(managersCollection)
        .doc(manager.id.toString())
        .set(manager.toMap());
  }

  Future<void> createDeveloper(Developer developer) async {
    await _db
        .collection(developersCollection)
        .doc(developer.id.toString())
        .set(developer.toMap());
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
    // Buscar pelo UID do Firebase Auth (que continua sendo String)
    // mas comparar com o campo idUser que agora é int
    // Precisamos converter uid para int se for necessário
    final userDoc = await _db.collection(usersCollection).doc(uid).get();
    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>;
    final int userId = userData['id'] ?? 0;

    final query = await _db
        .collection(managersCollection)
        .where('idUser', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Manager.fromFirestore(query.docs.first);
    }
    return null;
  }

  Future<Developer?> getDeveloperByUserId(String uid) async {
    // Buscar pelo UID do Firebase Auth (que continua sendo String)
    // mas comparar com o campo idUser que agora é int
    final userDoc = await _db.collection(usersCollection).doc(uid).get();
    if (!userDoc.exists) return null;

    final userData = userDoc.data() as Map<String, dynamic>;
    final int userId = userData['id'] ?? 0;

    final query = await _db
        .collection(developersCollection)
        .where('idUser', isEqualTo: userId)
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

  // User CRUD operations completed - see updateUserComplete and deleteUserComplete methods

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

  Future<List<Task>> getTasks() async {
    final querySnapshot = await _db.collection(tasksCollection).get();
    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  /// Check if a task with the same order already exists for a developer
  /// Returns true if the order is available (can be used)
  Future<bool> canCreateTaskWithOrder({
    required int developerId,
    required int order,
    String? excludeTaskId, // For edit scenario
  }) async {
    var query = _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .where('order', isEqualTo: order);

    final querySnapshot = await query.get();

    // If editing, exclude the current task from check
    if (excludeTaskId != null) {
      return querySnapshot.docs.every((doc) => doc.id == excludeTaskId);
    }

    return querySnapshot.docs.isEmpty;
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

  /// Update task with validation
  Future<void> updateTask(Task task) async {
    // Validate order is not duplicated (excluding current task)
    final canUpdate = await canCreateTaskWithOrder(
      developerId: task.idDeveloper,
      order: task.order,
      excludeTaskId: task.id,
    );

    if (!canUpdate) {
      throw Exception(
        'Já existe outra tarefa com ordem ${task.order} para este programador',
      );
    }

    await _db.collection(tasksCollection).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection(tasksCollection).doc(taskId).delete();
  }

  Future<List<Task>> getCompletedTasksForManager(int managerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idManager', isEqualTo: managerId)
        .where('taskStatus', isEqualTo: 'Done')
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getOngoingTasksForManager(int managerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idManager', isEqualTo: managerId)
        .where('taskStatus', whereIn: ['ToDo', 'Doing'])
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getCompletedTasksForDeveloper(int developerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .where('taskStatus', isEqualTo: 'Done')
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  Future<List<Task>> getTasksByDeveloper(int developerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .get();

    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  /// Get completed tasks for calculating StoryPoints average
  Future<List<Task>> getCompletedTasks() async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('taskStatus', isEqualTo: 'Done')
        .get();
    return querySnapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
  }

  /// Get ToDo tasks for a specific developer
  Future<List<Task>> getTodoTasksByDeveloper(int developerId) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('idDeveloper', isEqualTo: developerId)
        .where('taskStatus', isEqualTo: 'ToDo')
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
    final docId = manager.docId ?? manager.id.toString();
    await _db
        .collection(managersCollection)
        .doc(docId)
        .update(manager.toMap());
  }

  Future<void> deleteManager(String managerId) async {
    await _db.collection(managersCollection).doc(managerId).delete();
  }

  Future<void> updateDeveloper(Developer developer) async {
    final docId = developer.docId ?? developer.id.toString();
    await _db
        .collection(developersCollection)
        .doc(docId)
        .update(developer.toMap());
  }

  Future<void> deleteDeveloper(String developerId) async {
    await _db.collection(developersCollection).doc(developerId).delete();
  }

  /// Complete user update - updates AppUser and specific profile (Manager/Developer)
  Future<void> updateUserComplete({
    required String uid,
    required AppUser appUser,
    Manager? manager,
    Developer? developer,
  }) async {
    // Update AppUser
    await updateUser(uid, appUser);

    // Update or create specific profile
    if (appUser.type == 'Manager' && manager != null) {
      // Check if Manager exists
      final existingManager = await getManagerByUserId(uid);
      if (existingManager != null) {
        // Update existing - preserve docId
        final managerToUpdate = Manager(
          id: manager.id,
          name: manager.name,
          department: manager.department,
          idUser: manager.idUser,
          docId: existingManager.docId,
        );
        await updateManager(managerToUpdate);
      } else {
        // Create new Manager
        await _db.collection(managersCollection).doc(manager.id.toString()).set(manager.toMap());
      }
    } else if (appUser.type == 'Developer' && developer != null) {
      // Check if Developer exists
      final existingDeveloper = await getDeveloperByUserId(uid);
      if (existingDeveloper != null) {
        // Update existing - preserve docId
        final developerToUpdate = Developer(
          id: developer.id,
          name: developer.name,
          experienceLevel: developer.experienceLevel,
          idUser: developer.idUser,
          idManager: developer.idManager,
          docId: existingDeveloper.docId,
        );
        await updateDeveloper(developerToUpdate);
      } else {
        // Create new Developer (for legacy users without profile)
        await _db.collection(developersCollection).doc(developer.id.toString()).set(developer.toMap());
      }
    }
  }

  /// Complete user deletion - deletes AppUser, profile, and optionally Auth account
  /// This implements cascade delete to maintain data integrity
  Future<void> deleteUserComplete({
    required String uid,
    required AppUser appUser,
    required bool deleteFromAuth, // If true, also deletes from Firebase Auth
  }) async {
    try {
      // Step 1: Delete specific profile (Manager or Developer)
      if (appUser.type == 'Manager') {
        final manager = await getManagerByUserId(uid);
        if (manager != null) {
          // Use docId if available, otherwise use id
          final docId = manager.docId ?? manager.id.toString();
          await deleteManager(docId);
          LoggerService.info('Deleted Manager profile: $docId');
        } else {
          // Fallback: try to delete by appUser.id (for legacy/inconsistent data)
          try {
            await deleteManager(appUser.id.toString());
            LoggerService.info('Deleted Manager profile (fallback): ${appUser.id}');
          } catch (e) {
            LoggerService.warning('Manager profile not found for deletion: ${appUser.id}');
          }
        }
      } else if (appUser.type == 'Developer') {
        final developer = await getDeveloperByUserId(uid);
        if (developer != null) {
          // Use docId if available, otherwise use id
          final docId = developer.docId ?? developer.id.toString();
          await deleteDeveloper(docId);
          LoggerService.info('Deleted Developer profile: $docId');
        } else {
          // Fallback: try to delete by appUser.id (for legacy/inconsistent data)
          try {
            await deleteDeveloper(appUser.id.toString());
            LoggerService.info('Deleted Developer profile (fallback): ${appUser.id}');
          } catch (e) {
            LoggerService.warning('Developer profile not found for deletion: ${appUser.id}');
          }
        }
      }

      // Step 2: Delete AppUser document
      await deleteUser(uid);
      LoggerService.info('Deleted AppUser: $uid');

      // Step 3: Delete from Firebase Auth (if requested)
      // Note: This should be done by the calling code with admin privileges
      if (deleteFromAuth) {
        LoggerService.warning(
          'Auth deletion requested for $uid - this should be handled by admin/manager',
        );
      }
    } catch (e) {
      LoggerService.error('Error in cascade delete for user $uid', e);
      rethrow;
    }
  }

  Future<List<Manager>> getAllManagers() async {
    final querySnapshot = await _db.collection(managersCollection).get();
    return querySnapshot.docs.map((doc) => Manager.fromFirestore(doc)).toList();
  }

  Future<List<Developer>> getAllDevelopers() async {
    final querySnapshot = await _db.collection(developersCollection).get();
    return querySnapshot.docs
        .map((doc) => Developer.fromFirestore(doc))
        .toList();
  }

  // --- TASK TYPES ---

  Future<void> createTaskType(TaskTypeModel taskType) async {
    await _db
        .collection(taskTypesCollection)
        .doc(taskType.id.toString())
        .set(taskType.toMap());
  }

  Stream<List<TaskTypeModel>> getTaskTypesStream() {
    return _db.collection(taskTypesCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskTypeModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<List<TaskTypeModel>> getTaskTypes() async {
    final querySnapshot = await _db.collection(taskTypesCollection).get();
    return querySnapshot.docs
        .map((doc) => TaskTypeModel.fromFirestore(doc))
        .toList();
  }

  Future<void> updateTaskType(TaskTypeModel taskType) async {
    // Usa o docId se disponível, senão usa o id convertido
    final docId = taskType.docId ?? taskType.id.toString();
    LoggerService.info('FirestoreService: Atualizando task type com docId: $docId');
    
    await _db
        .collection(taskTypesCollection)
        .doc(docId)
        .update(taskType.toMap());
  }

  Future<void> deleteTaskType(String taskTypeId) async {
    LoggerService.info('FirestoreService: Tentando apagar task type com ID: $taskTypeId');
    try {
      await _db
          .collection(taskTypesCollection)
          .doc(taskTypeId)
          .delete();
      LoggerService.info('FirestoreService: Task type $taskTypeId apagado com sucesso');
    } catch (e) {
      LoggerService.error('FirestoreService: Erro ao apagar task type $taskTypeId', e);
      rethrow;
    }
  }
}
