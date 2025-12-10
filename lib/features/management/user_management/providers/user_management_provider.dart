import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/developer_model.dart';

class UserManagementProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  List<AppUser> _users = [];
  List<Manager> _managers = [];
  List<Developer> _developers = [];
  bool _isLoading = false;

  List<AppUser> get users => _users;
  List<Manager> get managers => _managers;
  List<Developer> get developers => _developers;
  bool get isLoading => _isLoading;

  UserManagementProvider(this._firestoreService, this._authService);
  
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _firestoreService.getUsers();
    } catch (e) {
      LoggerService.error("Erro ao buscar users", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchManagers() async {
    try {
      _managers = await _firestoreService.getManagers();
      notifyListeners();
    } catch (e) {
      LoggerService.error("Erro ao buscar managers", e);
    }
  }

  Future<void> fetchDevelopers() async {
    try {
      _developers = await _firestoreService.getAllDevelopers();
      notifyListeners();
    } catch (e) {
      LoggerService.error("Erro ao buscar developers", e);
    }
  }

  Future<String?> createNewUser({
    required String email,
    required String password,
    required AppUser appUser,
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bool isUnique = await _firestoreService.isUsernameUnique(
        appUser.username,
      );
      if (!isUnique) {
        _isLoading = false;
        notifyListeners();
        return "Erro: O Username '${appUser.username}' já está a ser utilizado.";
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Erro ao verificar username: $e";
    }

    late UserCredential userCredential;

    try {
      print('🔄 Criando utilizador em Firebase Auth...');
      final credential = await _authService.createUserInAuth(
        email: email,
        password: password,
      );

      if (credential == null || credential.user == null) {
        _isLoading = false;
        notifyListeners();
        print('❌ Credential null ou user null');
        return "Erro desconhecido ao criar utilizador.";
      }
      userCredential = credential;
      print('✅ UserCredential obtido: ${userCredential.user?.email}');
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.code == 'email-already-in-use') {
        return 'Erro: O email fornecido já está a ser utilizado.';
      }
      if (e.code == 'weak-password') {
        return 'Erro: A password é demasiado fraca.';
      }
      return 'Erro de autenticação: ${e.code}';
    }

    final uid = userCredential.user!.uid;

    try {
      final int userId = await _firestoreService.getNextUserId();

      AppUser newUser = AppUser(
        id: userId,
        uid: uid,
        name: appUser.name,
        username: appUser.username,
        email: email,
        type: appUser.type,
      );

      await _firestoreService.createUser(newUser, uid);

      if (appUser.type == 'Manager' && manager != null) {
        final int managerId = await _firestoreService.getNextManagerId();
        Manager newManager = Manager(
          id: managerId,
          name: appUser.name,
          department: manager.department,
          idUser: userId,
        );
        await _firestoreService.createManager(newManager);
      } else if (appUser.type == 'Developer' && developer != null) {
        final int developerId = await _firestoreService.getNextDeveloperId();
        Developer newDeveloper = Developer(
          id: developerId,
          name: appUser.name,
          experienceLevel: developer.experienceLevel,
          idUser: userId,
          idManager: developer.idManager,
        );
        await _firestoreService.createDeveloper(newDeveloper);
      }

      await fetchUsers();

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      try {
        await userCredential.user!.delete();
      } catch (deleteError) {
        LoggerService.error(
          'Falha crítica: User criado no Auth mas falhou na BD e falhou ao apagar.',
          deleteError,
        );
      }

      LoggerService.error('Erro ao criar user na BD', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao guardar dados: $e";
    }
  }

  Future<String?> updateUser({
    required String uid,
    required AppUser appUser,
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _firestoreService.getUserById(uid);
      if (currentUser != null && currentUser.username != appUser.username) {
        final isUnique = await _firestoreService.isUsernameUnique(
          appUser.username,
        );
        if (!isUnique) {
          _isLoading = false;
          notifyListeners();
          return "Erro: O Username '${appUser.username}' já está a ser utilizado.";
        }
      }

      await _firestoreService.updateUserComplete(
        uid: uid,
        appUser: appUser,
        manager: manager,
        developer: developer,
      );

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      LoggerService.error('Error updating user', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao atualizar utilizador: ${e.toString()}";
    }
  }

  Future<String?> deleteUser({
    required String uid,
    required AppUser appUser,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info('deleteUser: uid=$uid, type=${appUser.type}');
      
      if (appUser.type == 'Developer') {
        LoggerService.info('Verificando tarefas do developer...');
        final developer = await _firestoreService.getDeveloperByUserId(uid);
        LoggerService.info('Developer encontrado: ${developer?.id}');
        
        if (developer != null) {
          final tasks = await _firestoreService.getTasksByDeveloper(
            developer.id,
          );
          LoggerService.info('Tarefas encontradas: ${tasks.length}');
          
          if (tasks.isNotEmpty) {
            _isLoading = false;
            notifyListeners();
            return "Erro: Não é possível eliminar programador com tarefas atribuídas. "
                "Reatribua as ${tasks.length} tarefa(s) primeiro.";
          }
        }
      }

      if (appUser.type == 'Manager') {
        LoggerService.info('Verificando developers do manager...');
        final manager = await _firestoreService.getManagerByUserId(uid);
        LoggerService.info('Manager encontrado: ${manager?.id}');
        
        if (manager != null) {
          final allDevelopers = await _firestoreService.getAllDevelopers();
          final assignedDevs = allDevelopers
              .where((d) => d.idManager == manager.id)
              .toList();
          LoggerService.info('Developers atribuídos: ${assignedDevs.length}');
          
          if (assignedDevs.isNotEmpty) {
            _isLoading = false;
            notifyListeners();
            return "Erro: Não é possível eliminar gestor com programadores atribuídos. "
                "Reatribua os ${assignedDevs.length} programador(es) primeiro.";
          }
        }
      }

      LoggerService.info('Executando deleteUserComplete...');
      await _firestoreService.deleteUserComplete(
        uid: uid,
        appUser: appUser,
        deleteFromAuth: false,
      );

      LoggerService.info('Delete concluído com sucesso');
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      LoggerService.error('Error deleting user', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao eliminar utilizador: ${e.toString()}";
    }
  }
}
