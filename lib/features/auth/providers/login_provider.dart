// features/auth/providers/login_provider.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/core/models/app_user_model.dart'; // Importe o modelo base

enum LoginState { idle, loading, error }

class LoginProvider extends ChangeNotifier {
  final AuthService _authService;
  final AuthProvider _authProvider;

  LoginState _state = LoginState.idle;
  LoginState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // O LoginProvider precisa dos serviços core para funcionar
  LoginProvider({
    required AuthService authService,
    required AuthProvider authProvider,
  }) : _authService = authService,
       _authProvider = authProvider;

  // Função principal chamada pelo botão de login
  Future<bool> login(String email, String password) async {
    _setState(LoginState.loading);

    try {
      // 1. Chamar o serviço de autenticação (que o seu colega está a fazer)
      // Este serviço deve lidar com o Firebase Auth E com o Firestore
      // para ir buscar os dados do Manager/Developer.
      AppUser? user = await _authService.loginWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // 2. Se o login for bem-sucedido, informar o AuthProvider global
        _authProvider.setUser(user);
        _setState(LoginState.idle);
        return true; // Sucesso
      } else {
        // Caso em que o authService retorna nulo por alguma razão (ex: user não encontrado no firestore)
        _setError('Utilizador não encontrado.');
        return false; // Falha
      }
    } catch (e) {
      // 3. Se houver um erro (ex: password errada), capturar e mostrar
      _setError(e.toString());
      return false; // Falha
    }
  }

  void _setState(LoginState newState) {
    _state = newState;
    if (newState != LoginState.error) {
      _errorMessage = null; // Limpa erros se o estado não for de erro
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = LoginState.error;
    notifyListeners();
  }
}
