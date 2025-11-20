// features/management/user_management/screens/user_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importe os seus widgets
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';

// Constantes baseadas no enunciado
enum UserRole { programador, gestor }

enum NivelExperiencia { junior, pleno, senior }

enum Departamento { mobile, web, qa, design }

class UserEditScreen extends StatefulWidget {
  // Se 'user' for nulo, estamos a criar.
  // Caso contrário, estamos a editar.
  final dynamic user; // Temporário. Será 'AppUser'

  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController(); // O email/username
  final _passwordController = TextEditingController();

  // Variáveis de estado para os Dropdowns
  UserRole _selectedRole = UserRole.programador;
  NivelExperiencia _selectedNivel = NivelExperiencia.junior;
  Departamento _selectedDepartamento = Departamento.mobile;
  int? _selectedManagerId; // Para o Programador

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // TODO: Preencher os controladores com os dados do 'widget.user'
      // Ex: _nameController.text = widget.user['name'];
      // Ex: _selectedRole = widget.user['role'] == 'Gestor' ? UserRole.gestor : UserRole.programador;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Chamar o Provider para salvar os dados
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Utilizador' : 'Novo Utilizador'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campos Comuns ---
              _buildRoleSelector(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                hintText: 'Nome Completo',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
                    return 'Nome deve conter apenas letras';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                hintText: 'Username (Email)',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email é obrigatório';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email inválido';
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
                validator: (val) {
                  if (!_isEditing) {
                    // Para novo usuário, password é obrigatória
                    if (val == null || val.isEmpty) {
                      return 'Password é obrigatória';
                    }
                    if (val.length < 6) {
                      return 'Password deve ter pelo menos 6 caracteres';
                    }
                    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(val)) {
                      return 'Password deve conter letras e números';
                    }
                  } else {
                    // Para edição, password é opcional, mas se preenchida deve ser válida
                    if (val != null && val.isNotEmpty) {
                      if (val.length < 6) {
                        return 'Password deve ter pelo menos 6 caracteres';
                      }
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(val)) {
                        return 'Password deve conter letras e números';
                      }
                    }
                  }
                  return null;
                },
                // Nota: No modo de edição, a password pode ser opcional
                // (só se altera se for preenchida)
              ),
              const SizedBox(height: 24),

              // --- Campos Condicionais ---
              // Mostra campos de Programador
              if (_selectedRole == UserRole.programador)
                ..._buildDeveloperFields(),

              // Mostra campos de Gestor
              if (_selectedRole == UserRole.gestor) ..._buildManagerFields(),

              const SizedBox(height: 32),
              CustomButton(text: 'Salvar', onPressed: _saveForm),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o seletor de Role (Programador/Gestor)
  Widget _buildRoleSelector() {
    return DropdownButtonFormField<UserRole>(
      initialValue: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Função',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.badge),
      ),
      items: UserRole.values
          .map(
            (role) => DropdownMenuItem(
              value: role,
              // Capitaliza o nome (ex: "programador" -> "Programador")
              child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
            ),
          )
          .toList(),
      onChanged: _isEditing
          ? null
          : (value) {
              // Não deixa mudar a role ao editar
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
    );
  }

  // Lista de widgets para campos de Programador
  List<Widget> _buildDeveloperFields() {
    final userManagementProvider = Provider.of<UserManagementProvider>(context, listen: false);
    final managers = userManagementProvider.managers;

    return [
      DropdownButtonFormField<NivelExperiencia>(
        initialValue: _selectedNivel,
        decoration: InputDecoration(
          labelText: 'Nível de Experiência *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.star_border),
        ),
        validator: (value) {
          if (value == null) {
            return 'Selecione o nível de experiência';
          }
          return null;
        },
        items: NivelExperiencia.values
            .map(
              (nivel) => DropdownMenuItem(
                value: nivel,
                child: Text(
                  nivel.name[0].toUpperCase() + nivel.name.substring(1),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedNivel = value!),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<int>(
        initialValue: _selectedManagerId,
        hint: Text('Selecionar Gestor'),
        decoration: InputDecoration(
          labelText: 'Gestor Responsável *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.supervisor_account),
        ),
        validator: (value) {
          if (value == null) {
            return 'Selecione um gestor responsável';
          }
          return null;
        },
        items: mockManagers.entries
        items: managers
            .map(
              (manager) => DropdownMenuItem(
                value: manager.id,
                child: Text(manager.name),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedManagerId = value),
      ),
    ];
  }

  // Lista de widgets para campos de Gestor
  List<Widget> _buildManagerFields() {
    return [
      DropdownButtonFormField<Departamento>(
        initialValue: _selectedDepartamento,
        decoration: InputDecoration(
          labelText: 'Departamento *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.business),
        ),
        validator: (value) {
          if (value == null) {
            return 'Selecione o departamento';
          }
          return null;
        },
        items: Departamento.values
            .map(
              (dep) => DropdownMenuItem(
                value: dep,
                child: Text(dep.name.toUpperCase()),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedDepartamento = value!),
      ),
    ];
  }
}
