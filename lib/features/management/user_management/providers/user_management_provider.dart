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

  List<AppUser> _users = []; // CORRIGIDO: Removido 'final'
  bool _isLoading = false;

  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;

  UserManagementProvider(this._firestoreService, this._authService) {
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    _users = await _firestoreService.getUsers();
    _isLoading = false;
    notifyListeners();
  }

  // CORRIGIDO: Devolve String? de erro em vez de bool
  Future<String?> createNewUser({
    required String email,
    required String password,
    required AppUser appUser, // Este é um 'template' com nome, username, type
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    // --- PASSO 1: VERIFICAR REGRA DE NEGÓCIO (USERNAME ÚNICO) ---
    final bool isUnique = await _firestoreService.isUsernameUnique(
      appUser.username,
    );
    if (!isUnique) {
      _isLoading = false;
      notifyListeners();
      return "Erro: O Username '${appUser.username}' já está a ser utilizado.";
    }

    // --- PASSO 2: CRIAR NO AUTH ---
    // Usamos 'late' porque o userCredential só é preciso no 'catch'
    late UserCredential userCredential;

    try {
      final credential = await _authService.createUserInAuth(
        email: email,
        password: password,
      );

      if (credential == null || credential.user == null) {
        _isLoading = false;
        notifyListeners();
        return "Erro ao criar utilizador (ex: email já existe ou password fraca).";
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
        id: userId, // Usar ID gerado
        name: appUser.name,
        username: appUser.username,
        email: email, // Usar o email real
        type: appUser.type,
      );
      await _firestoreService.createUser(newUser, uid);

      // 3.2 Criar o Manager ou Developer
      if (appUser.type == 'Manager' && manager != null) {
        final int managerId = await _firestoreService.getNextManagerId();
        Manager newManager = Manager(
          id: managerId,
          name: appUser.name,
          department: manager.department,
          idUser: userId, // Referenciar o AppUser.id
        );
        // CORRIGIDO: Passar só o 'newManager'
        await _firestoreService.createManager(newManager);
      } else if (appUser.type == 'Developer' && developer != null) {
        final int developerId = await _firestoreService.getNextDeveloperId();
        Developer newDeveloper = Developer(
          id: developerId,
          name: appUser.name,
          experienceLevel: developer.experienceLevel,
          idUser: userId, // Referenciar o AppUser.id
          idManager: developer.idManager,
        );
        // CORRIGIDO: Passar só o 'newDeveloper'
        await _firestoreService.createDeveloper(newDeveloper);
      } else {
        // Se o tipo não for válido ou o objeto for nulo
        throw Exception("Tipo de utilizador inválido ou dados em falta.");
      }

      _isLoading = false;
      notifyListeners();
      return null; // Sucesso
    } catch (e) {
      // --- PASSO 4: ROLLBACK (DESFAZER) ---
      // Se a base de dados falhar, apagar o utilizador do Auth
      // para não deixar lixo
      await userCredential.user!.delete();
      LoggerService.error('Error creating user in DB, rollback auth', e);
      _isLoading = false;
      notifyListeners();
      return "Erro ao guardar dados do utilizador na base de dados.";
    }
  }

  // TODO: Adicionar métodos para updateUser e deleteUser
}
