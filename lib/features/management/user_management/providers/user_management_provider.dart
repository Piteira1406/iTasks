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
  
  // CORREÇÃO: Tornei este método público (sem o underscore _)
  // Assim podes chamar provider.fetchUsers() noutros ecrãs se precisares
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
    required AppUser appUser, // Template com nome, username, type
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    // --- PASSO 1: VERIFICAR USERNAME ÚNICO ---
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
      // Se der erro a verificar, assumimos que não dá para continuar
      _isLoading = false;
      notifyListeners();
      return "Erro ao verificar username: $e";
    }

    // --- PASSO 2: CRIAR NO AUTH ---
    late UserCredential userCredential;

    try {
      final credential = await _authService.createUserInAuth(
        email: email,
        password: password,
      );

      if (credential == null || credential.user == null) {
        _isLoading = false;
        notifyListeners();
        return "Erro desconhecido ao criar utilizador.";
      }
      userCredential = credential;
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

    // --- PASSO 3: CRIAR NA BASE DE DADOS ---
    try {
      // Gerar IDs únicos
      final int userId = await _firestoreService.getNextUserId();

      // 3.1 Criar o AppUser (na coleção 'Users')
      AppUser newUser = AppUser(
        id: userId,
        uid: uid, // Firebase Auth UID
        name: appUser.name,
        username: appUser.username,
        email: email,
        type: appUser.type,
      );

      await _firestoreService.createUser(newUser, uid);

      // 3.2 Criar o Manager ou Developer
      if (appUser.type == 'Manager' && manager != null) {
        final int managerId = await _firestoreService.getNextManagerId();
        Manager newManager = Manager(
          id: managerId, // Firestore gera
          name: appUser.name,
          department: manager.department,
          idUser: userId, // Liga ao Auth UID
        );
        await _firestoreService.createManager(newManager);
      } else if (appUser.type == 'Developer' && developer != null) {
        // Mudei para Developer (estava Programador no texto antigo, mas o objeto é Developer)
        final int developerId = await _firestoreService.getNextDeveloperId();
        Developer newDeveloper = Developer(
          id: developerId, // Firestore gera
          name: appUser.name,
          experienceLevel: developer.experienceLevel,
          idUser: userId, // Liga ao Auth UID
          idManager: developer.idManager,
        );
        await _firestoreService.createDeveloper(newDeveloper);
      }
      // Nota: Se for 'Programador' mas não houver objeto developer,
      // a lógica anterior lançava exceção. Mantive assim, mas garante que o UI envia os dados.

      // --- MELHORIA: ATUALIZAR A LISTA LOCAL ---
      // Assim o novo user aparece logo na lista sem reiniciar a app
      await fetchUsers();

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso (null significa sem erro)
    } catch (e) {
      // --- PASSO 4: ROLLBACK ---
      // Se falhar na BD, apaga do Auth
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

  /// Update existing user with complete profile
  Future<String?> updateUser({
    required String uid,
    required AppUser appUser,
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validation: If changing username, check it's unique
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

      // Update user and profile
      await _firestoreService.updateUserComplete(
        uid: uid,
        appUser: appUser,
        manager: manager,
        developer: developer,
      );

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      LoggerService.error('Error updating user', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao atualizar utilizador: ${e.toString()}";
    }
  }

  /// Delete user with cascade (profile + auth)
  Future<String?> deleteUser({
    required String uid,
    required AppUser appUser,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      LoggerService.info('deleteUser: uid=$uid, type=${appUser.type}');
      
      // Check if user has assigned tasks
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

      // Check if Manager has developers assigned
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

      // Perform cascade delete
      LoggerService.info('Executando deleteUserComplete...');
      await _firestoreService.deleteUserComplete(
        uid: uid,
        appUser: appUser,
        deleteFromAuth:
            false, // Don't delete from Auth - only managers can do this
      );

      LoggerService.info('Delete concluído com sucesso');
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      LoggerService.error('Error deleting user', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao eliminar utilizador: ${e.toString()}";
    }
  }

  // TODO: Adicionar métodos para updateUser e deleteUser
}
