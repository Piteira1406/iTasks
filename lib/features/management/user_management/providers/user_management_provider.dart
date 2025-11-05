import 'package:flutter/material.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/developer_model.dart';

class UserManagementProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;

  final List<AppUser> _users = [];
  bool _isLoading = false;

  List<AppUser> get users => _users;
  bool get isLoading => _isLoading;

  UserManagementProvider(this._firestoreService, this._authService) {
    // TODO: Implementar 'getUsersStream' no FirestoreService
    // para que esta lista se atualize em tempo real.
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implementar 'getUsers' (Future) no FirestoreService
    // _users = await _firestoreService.getUsers();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createNewUser({
    required String email,
    required String password,
    required AppUser appUser,
    Manager? manager,
    Developer? developer,
  }) async {
    _isLoading = true;
    notifyListeners();

    final userCredential = await _authService.createUserInAuth(
      email: email,
      password: password,
    );

    if (userCredential == null || userCredential.user == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final uid = userCredential.user!.uid;

    try {
      AppUser newUser = AppUser(
        id: uid,
        name: appUser.name,
        username: appUser.username,
        email: email,
        type: appUser.type,
      );
      await _firestoreService.createUtilizador(newUser, uid);

      if (appUser.type == 'Manager' && manager != null) {
        Manager newManager = Manager(
          id: '',
          name: appUser.name,
          department: manager.department,
          idUser: uid,
        );
        await _firestoreService.createManager(newManager, uid);
      } else if (appUser.type == 'Developer' && developer != null) {
        Developer newDeveloper = Developer(
          id: '',
          name: appUser.name,
          experienceLevel: developer.experienceLevel,
          idUser: uid,
          idManager: developer.idManager,
        );
        await _firestoreService.createDeveloper(newDeveloper, uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // TODO: Idealmente, devíamos apagar o utilizador do Auth
      print('Error creating user: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // TODO: Adicionar métodos para updateUser e deleteUser
}
