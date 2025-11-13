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
  bool _isLoading = false;

  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;

  UserManagementProvider(this._firestoreService, this._authService) {
    fetchUsers(); // Chama a versão pública
  }

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
      // 3.1 Criar o AppUser
      AppUser newUser = AppUser(
        id: uid.hashCode,
        name: appUser.name,
        username: appUser.username,
        email: email,
        type: appUser.type,
      );

      await _firestoreService.createUser(newUser, uid);

      // 3.2 Criar o Manager ou Developer
      if (appUser.type == 'Manager' && manager != null) {
        Manager newManager = Manager(
          id: '', // Firestore gera
          name: appUser.name,
          department: manager.department,
          idUser: uid, // Liga ao Auth UID
        );
        await _firestoreService.createManager(newManager);
      } else if (appUser.type == 'Developer' && developer != null) {
        // Mudei para Developer (estava Programador no texto antigo, mas o objeto é Developer)
        Developer newDeveloper = Developer(
          id: 0, // Firestore gera
          name: appUser.name,
          experienceLevel: developer.experienceLevel,
          idUser: uid, // Liga ao Auth UID
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
}
