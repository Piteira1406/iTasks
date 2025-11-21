import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:itasks/core/services/logger_service.dart';
import 'package:itasks/features/auth/providers/login_provider.dart';
import 'package:itasks/features/auth/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    LoggerService.info('LoginScreen: A renderizar tela de login');
    // Vamos buscar o AuthService global que foi fornecido no main.dart
    final authService = context.read<AuthService>();

    // O ChangeNotifierProvider cria o LoginProvider *apenas* para este ecrã.
    // Quando o ecrã for destruído, o LoginProvider também é.
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(authService: authService),
      child: Scaffold(
        // Pode usar a sua ScrollFrostAppBar aqui se quiser
        appBar: AppBar(
          title: Text('iTasks Login'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // O corpo do ecrã é o formulário
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: LoginForm(), // O widget do formulário está em baixo
          ),
        ),
      ),
    );
  }
}