import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/services/firestore_service.dart';

// Modelos que tu enviaste
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/models/manager_model.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  AppUser? _appUser;

  // CORRIGIDO: Adicionado estado para os perfis específicos
  Manager? _managerProfile;
  Developer? _developerProfile;

  // Getters públicos
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  Manager? get managerProfile => _managerProfile;
  Developer? get developerProfile => _developerProfile;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ADICIONADO: Getters de permissão (para a UI usar)
  bool get isManager => _appUser?.type == 'Manager';
  bool get isDeveloper => _appUser?.type == 'Developer';

  AuthProvider(this._authService, this._firestoreService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    // Limpar dados ao fazer logout
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _appUser = null;
      _managerProfile = null;
      _developerProfile = null;
    } else {
      _firebaseUser = user;
      // Buscar todos os dados ao fazer login
      await _fetchAppUser(user.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> _fetchAppUser(String uid) async {
    // 1. Buscar o AppUser (da coleção 'Users')
    _appUser = await _firestoreService.getUserById(uid);

    // 2. CORRIGIDO: Buscar o perfil específico (Manager ou Developer)
    if (_appUser != null) {
      if (_appUser!.type == 'Manager') {
        // Usar o novo método do firestore_service
        _managerProfile = await _firestoreService.getManagerByUserId(uid);
      } else if (_appUser!.type == 'Developer') {
        // Usar o novo método do firestore_service
        _developerProfile = await _firestoreService.getDeveloperByUserId(uid);
      }
    }
    notifyListeners();
  }

  // CORRIGIDO: Devolve String? de erro em vez de bool
  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmail(email: email, password: password);
      // O listener _onAuthStateChanged trata de buscar os dados
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Sign in error', e);
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Email ou password inválidos.';
      }
      return 'Ocorreu um erro no login.';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}

  // A lógica de 'CreateUser' está (e deve ficar)
  // no 'UserManagementProvider', como tu já fizeste. 