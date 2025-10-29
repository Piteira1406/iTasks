import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/models/app_user_model.dart';
//import 'package:itasks/core/models/developer_model.dart';
//import 'package:itasks/core/models/manager_model.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthStatus _status = AuthStatus.uninitialized;
  User? _firebaseUser;
  AppUser? _appUser;
  //TODO: ADD DEVELOPER AND MANAGER

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider(this._authService, this._firestoreService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
    } else {
      _firebaseUser = user;
      await _fetchAppUser(user.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> _fetchAppUser(String uid) async {
    _appUser = await _firestoreService.getUtilizadorById(uid);

    if (_appUser != null) {
      if (_appUser!.type == 'Manager') {
        //TODO: CREATE getDeveloperById in FirestoreService
        //_developer = await _firestoreService.getDeveloperById(uid);
      } else if (_appUser!.type == 'Developer') {
        //TODO: CREATE getManagerById in FirestoreService
        //_manager = await _firestoreService.getManagerById(uid);
      }
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmail(email: email, password: password);
      return true;
    } catch (e) {
      print('SignIn Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  //TODO: ADD HERE 'CreateUser' logic
  //Call authService.createUserInAuth and
  //firestoreService.createUtilizador + createManager/createDeveloper based on user type
}
