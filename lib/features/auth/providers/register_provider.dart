// features/auth/providers/register_provider.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/services/auth_service.dart'; // (Use o nome do seu projeto)
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/models/app_user_model.dart'; // (O seu colega deve ter criado isto)
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/developer_model.dart';

class RegisterProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<bool> register({
    required AuthService authService,
    required FirestoreService firestoreService,
    required String email,
    required String password,
    required String name,
    required String role, // "Gestor" ou "Programador"
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // 1. Chamar o AuthService (que o seu colega fez) para criar o user
      // O AuthService deve tratar de criar o user no Firebase Auth E
      // criar o documento no Firestore com os dados (name, role, etc.)

      // Assumindo que o seu colega tem uma função registerUser no AuthService
      await authService.registerUser(
        email: email,
        password: password,
        name: name,
        role: role,
        // O registo normal não associa um gestor, isso é feito
        // no ecrã de "Gestão de Utilizadores"
        managerId: null,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Sucesso!
    } catch (e) {
      // Se o AuthService falhar (ex: email já existe), ele lança um erro
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Falhou
    }
  }
}
