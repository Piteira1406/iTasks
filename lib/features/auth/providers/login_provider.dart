// features/auth/providers/login_provider.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/services/auth_service.dart';

enum LoginState { idle, loading, error }

class LoginProvider extends ChangeNotifier {
  final AuthService _authService;

  LoginState _state = LoginState.idle;
  LoginState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // O LoginProvider precisa do AuthService para funcionar
  LoginProvider({required AuthService authService})
    : _authService = authService;

  // Função principal chamada pelo botão de login
  Future<bool> login(String email, String password) async {
    _setState(LoginState.loading);

    try {
      // 1. Chamar o serviço de autenticação do Firebase
      final userCredential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userCredential != null && userCredential.user != null) {
        // 2. O AuthProvider irá automaticamente detectar a mudança de estado
        // através do authStateChanges.listen() e buscar os dados do Firestore
        // Não é necessário chamar _authProvider.setUser()

        _setState(LoginState.idle);
        return true; // Sucesso
      } else {
        // Login falhou (credenciais inválidas)
        _setError('Email ou password incorretos.');
        return false; // Falha
      }
    } catch (e) {
      // 3. Se houver um erro, capturar e mostrar
      _setError('Erro ao fazer login: ${e.toString()}');
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
