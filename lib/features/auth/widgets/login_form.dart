// features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/core/widgets/custom_snackbar.dart';
import 'package:itasks/core/widgets/glass_card.dart'; // O seu widget de Glassmorphism
import 'package:itasks/core/widgets/loading_spinner.dart';
import 'package:itasks/features/auth/providers/login_provider.dart';
import 'package:itasks/core/services/auth_service.dart';
import 'package:provider/provider.dart';
// Imports relativos para os widgets do core

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // 1. Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Chamar o provider para fazer o login
    // Usamos context.read() porque estamos dentro de uma função
    final loginProvider = context.read<LoginProvider>();
    await loginProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Se o login falhar, o provider vai atualizar o seu estado
    // e o `build` em baixo vai mostrar a mensagem de erro.
    // Se o login for bem-sucedido, o AuthProvider global
    // vai ser atualizado e o main.dart vai navegar para o KanbanScreen.
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Introduza o email da conta para receber um link de recuperação de password.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                CustomSnackBar.showError(dialogContext, 'Email inválido');
                return;
              }
              
              Navigator.of(dialogContext).pop();
              
              final authService = context.read<AuthService>();
              final error = await authService.sendPasswordResetEmail(email: email);
              
              if (mounted) {
                if (error == null) {
                  CustomSnackBar.showSuccess(
                    context,
                    'Email de recuperação enviado! Verifique a sua caixa de entrada.',
                  );
                } else {
                  CustomSnackBar.showError(context, error);
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch() para que o widget reconstrua
    // quando o estado (loading, error) mudar.
    final loginProvider = context.watch<LoginProvider>();

    return GlassCard(
      // Usando o seu widget de Glassmorphism
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bem-vindo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Lógica de Loading/Botão ---
              if (loginProvider.state == LoginState.loading)
                const LoadingSpinner() // O seu widget de loading
              else
                CustomButton(
                  text: 'Login',
                  onPressed: _submitLogin, // Chama a função de submit
                ),

              const SizedBox(height: 12),

              // --- Botão Esqueci a Password ---
              TextButton(
                onPressed: _showForgotPasswordDialog,
                child: const Text(
                  'Esqueci a password',
                  style: TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 8),

              // --- Lógica de Erro ---
              if (loginProvider.state == LoginState.error &&
                  loginProvider.errorMessage != null)
                Text(
                  loginProvider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
