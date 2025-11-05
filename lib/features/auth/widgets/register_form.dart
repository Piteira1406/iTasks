// features/auth/widgets/register_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/services/auth_service.dart'; // (Use o nome do seu projeto)
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_textfield.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/loading_spinner.dart';
import 'package:itasks/features/auth/providers/register_provider.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Opções para o dropdown
  final List<String> _userRoles = ['Programador', 'Gestor'];
  String _selectedRole = 'Programador'; // Valor inicial

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister(RegisterProvider provider) async {
    if (_formKey.currentState!.validate()) {
      // Lê os serviços globais que o main.dart fornece
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();

      final success = await provider.register(
        authService: authService,
        firestoreService: firestoreService,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        role: _selectedRole,
      );

      if (success && mounted) {
        // Se o registo foi bem sucedido, mostra um aviso
        // e volta para o ecrã de login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Pode fazer login.'),
          ),
        );
        Navigator.of(context).pop(); // Volta para o LoginScreen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: Consumer<RegisterProvider>(
        builder: (context, provider, child) {
          return GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Criar Nova Conta',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),

                    // --- Campo Nome ---
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Nome Completo',
                      icon: Icons.person_outline,
                      validator: (val) =>
                          val!.isEmpty ? 'Insira o seu nome' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Campo Email ---
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                          val!.isEmpty ? 'Insira o email' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Campo Password ---
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: true,
                      validator: (val) => val!.length < 6
                          ? 'Password deve ter 6+ caracteres'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Dropdown Tipo de Utilizador ---
                    // (Usando um GlassCard para manter o estilo)
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          items: _userRoles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.work_outline),
                            border: InputBorder.none,
                          ),
                          dropdownColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),

                    // --- Erro e Botão ---
                    const SizedBox(height: 16),
                    if (provider.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          provider.errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    provider.isLoading
                        ? const LoadingSpinner()
                        : CustomButton(
                            text: 'Registar',
                            onPressed: () => _submitRegister(
                              context.read<RegisterProvider>(),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
