// features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/glass_card.dart'; // O seu widget de Glassmorphism
import '../../../core/widgets/loading_spinner.dart';
import '../../../features/auth/providers/login_provider.dart';
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

              const SizedBox(height: 16),

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
