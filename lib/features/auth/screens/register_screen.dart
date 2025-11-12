// features/auth/screens/register_screen.dart
// NOTE: This screen is NOT for public registration!
// User registration is ONLY done by Managers through the User Management Dashboard.
// This file is kept for potential future admin-only use.

import 'package:flutter/material.dart';
import 'package:itasks/features/auth/widgets/register_form.dart';

/// This screen should ONLY be accessible by authenticated Managers
/// through the User Management feature, not as a public registration page.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adicionamos uma AppBar para o utilizador poder voltar para trás
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: RegisterForm(),
        ),
      ),
    );
  }
}
