import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/core/services/firestore_service.dart';
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
  Manager? _managerProfile;
  Developer? _developerProfile;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  Manager? get managerProfile => _managerProfile;
  Developer? get developerProfile => _developerProfile;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isManager => _appUser?.type == 'Manager';
  bool get isDeveloper => _appUser?.type == 'Developer';

  AuthProvider(this._authService, this._firestoreService) {
    LoggerService.info('AuthProvider: Inicializando e escutando authStateChanges');
    
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _status = AuthStatus.unauthenticated;
      LoggerService.info('AuthProvider: Nenhum user logado inicialmente - STATUS: ${_status}');
      notifyListeners();
    }
    
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    LoggerService.info('AuthProvider: authStateChanged - user: ${user?.email ?? "null"}');
    
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _appUser = null;
      _managerProfile = null;
      _developerProfile = null;
    } else {
      _firebaseUser = user;
      await _fetchAppUser(user.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> _fetchAppUser(String uid) async {
    LoggerService.info('AuthProvider: Buscando AppUser para uid: $uid');
    _appUser = await _firestoreService.getUserById(uid);
    LoggerService.info('AuthProvider: AppUser encontrado: ${_appUser?.name}');

    if (_appUser != null) {
      if (_appUser!.type == 'Manager') {
        _managerProfile = await _firestoreService.getManagerByUserId(uid);
      } else if (_appUser!.type == 'Developer') {
        _developerProfile = await _firestoreService.getDeveloperByUserId(uid);
      }
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmail(email: email, password: password);
      return null;
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