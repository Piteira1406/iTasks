// features/management/user_management/screens/user_edit_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_textfield.dart';

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
  String? _selectedManagerId; // Para o Programador

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
      print("Formulário válido. A salvar...");
      print("Nome: ${_nameController.text}");
      print("Email: ${_usernameController.text}");
      print("Role: $_selectedRole");
      if (_selectedRole == UserRole.programador) {
        print("Nível: $_selectedNivel");
        print("Gestor ID: $_selectedManagerId");
      } else {
        print("Departamento: $_selectedDepartamento");
      }
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
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                hintText: 'Username (Email)',
                icon: Icons.email,
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock,
                obscureText: true,
                validator: (val) {
                  if (!_isEditing && val!.isEmpty) return 'Campo obrigatório';
                  if (_isEditing && val!.isNotEmpty && val.length < 6)
                    return 'Mínimo 6 caracteres';
                  if (!_isEditing && val!.length < 6)
                    return 'Mínimo 6 caracteres';
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
      value: _selectedRole,
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
    // TODO: A lista de gestores deve vir do Provider
    final mockManagers = {'gestor1': 'Ana Silva', 'gestor2': 'Rui Pedro'};

    return [
      DropdownButtonFormField<NivelExperiencia>(
        value: _selectedNivel,
        decoration: InputDecoration(
          labelText: 'Nível de Experiência',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.star_border),
        ),
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
      DropdownButtonFormField<String>(
        value: _selectedManagerId,
        hint: Text('Selecionar Gestor'),
        decoration: InputDecoration(
          labelText: 'Gestor Responsável',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.supervisor_account),
        ),
        items: mockManagers.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key, // ID do gestor
                child: Text(entry.value), // Nome do gestor
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _selectedManagerId = value),
        validator: (val) => val == null ? 'Campo obrigatório' : null,
      ),
    ];
  }

  // Lista de widgets para campos de Gestor
  List<Widget> _buildManagerFields() {
    return [
      DropdownButtonFormField<Departamento>(
        value: _selectedDepartamento,
        decoration: InputDecoration(
          labelText: 'Departamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(Icons.business),
        ),
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
