import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';

// Imports dos Models e Provider
import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';

// Constantes baseadas no enunciado
enum UserRole {
  programador,
  manager,
} // Mudei 'gestor' para 'manager' para bater certo com a BD

enum NivelExperiencia { junior, pleno, senior }

enum Departamento { mobile, web, qa, design }

class UserEditScreen extends StatefulWidget {
  final AppUser? user; // Tipado corretamente

  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController =
      TextEditingController(); // Adicionei controlador de email separado se necessário, ou usa-se o username
  final _passwordController = TextEditingController();

  // Estado dos Dropdowns
  UserRole _selectedRole = UserRole.programador;
  NivelExperiencia _selectedNivel = NivelExperiencia.junior;
  Departamento _selectedDepartamento = Departamento.mobile;
  String? _selectedManagerId;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();

    // Carregar utilizadores para preencher o dropdown de Gestores
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).fetchUsers();
    });

    if (_isEditing) {
      _nameController.text = widget.user!.name;
      _usernameController.text = widget.user!.username;
      _emailController.text = widget.user!.email;

      // Preencher o tipo
      if (widget.user!.type == 'Manager') {
        _selectedRole = UserRole.manager;
      } else {
        _selectedRole = UserRole.programador;
      }

      // TODO: Para edição completa, precisaríamos de buscar os dados extra
      // (Departamento do Manager ou Nivel/Gestor do Developer) à BD.
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função auxiliar para converter Enum para String Capitalizada (ex: "Mobile")
  String _enumToString(Object e) => e.toString().split('.').last.capitalize();

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<UserManagementProvider>(
      context,
      listen: false,
    );

    // 1. Preparar os objetos
    // Converter Enum para String que a BD espera ('Programador' ou 'Manager')
    String typeString = _selectedRole == UserRole.manager
        ? 'Manager'
        : 'Programador'; // ou 'Developer' se preferires

    final appUserTemplate = AppUser(
      id: 0, // Irrelevante na criação
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _usernameController.text
          .trim(), // Assumindo que username é email, senão usa _emailController
      type: typeString,
    );

    Manager? managerObj;
    Developer? devObj;

    if (_selectedRole == UserRole.manager) {
      managerObj = Manager(
        id: "",
        name: _nameController.text,
        department: _enumToString(_selectedDepartamento),
        idUser: '',
      );
    } else {
      devObj = Developer(
        id: "",
        name: _nameController.text,
        experienceLevel: _enumToString(_selectedNivel),
        idManager:
            _selectedManagerId ?? '', // Pode ser vazio se não tiver gestor
        idUser: '',
      );
    }

    // 2. Chamar o Provider
    final error = await provider.createNewUser(
      email: _usernameController.text.trim(), // Usando username como email
      password: _passwordController.text.trim(),
      appUser: appUserTemplate,
      manager: managerObj,
      developer: devObj,
    );

    if (!mounted) return;

    // 3. Tratar a resposta
    if (error == null) {
      // Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador criado com sucesso!')),
      );
      Navigator.of(context).pop();
    } else {
      // Erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserManagementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Utilizador' : 'Novo Utilizador'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Se estiver a carregar, mostra loading
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
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
                  hintText: 'Email (Username)',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.contains('@') ? null : 'Email inválido',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (val) {
                    if (!_isEditing && (val == null || val.isEmpty)) {
                      return 'Campo obrigatório';
                    }
                    if (val != null && val.isNotEmpty && val.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // --- Campos Condicionais ---
                if (_selectedRole == UserRole.programador)
                  ..._buildDeveloperFields(provider),
                if (_selectedRole == UserRole.manager) ..._buildManagerFields(),

                const SizedBox(height: 32),
                CustomButton(text: 'Salvar', onPressed: _saveForm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return DropdownButtonFormField<UserRole>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Função',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.badge),
      ),
      items: UserRole.values.map((role) {
        return DropdownMenuItem(value: role, child: Text(_enumToString(role)));
      }).toList(),
      onChanged: _isEditing
          ? null
          : (value) {
              if (value != null) setState(() => _selectedRole = value);
            },
    );
  }

  // Passamos o provider como argumento para aceder à lista de users
  List<Widget> _buildDeveloperFields(UserManagementProvider provider) {
    // FILTRO REAL: Buscar apenas quem é 'Manager'
    final managersList = provider.users
        .where((u) => u.type == 'Manager')
        .toList();

    return [
      DropdownButtonFormField<NivelExperiencia>(
        value: _selectedNivel,
        decoration: InputDecoration(
          labelText: 'Nível de Experiência',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.star_border),
        ),
        items: NivelExperiencia.values.map((nivel) {
          return DropdownMenuItem(
            value: nivel,
            child: Text(_enumToString(nivel)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedNivel = value!),
      ),
      const SizedBox(height: 16),

      // DROPDOWN REAL DE GESTORES
      DropdownButtonFormField<String>(
        value: _selectedManagerId,
        hint: const Text('Selecionar Gestor'),
        decoration: InputDecoration(
          labelText: 'Gestor Responsável',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.supervisor_account),
        ),
        items: managersList.map((manager) {
          return DropdownMenuItem(
            value: manager.id.toString(),
            child: Text(manager.name),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedManagerId = value),
        validator: (val) => val == null ? 'Selecione um gestor' : null,
      ),
    ];
  }

  List<Widget> _buildManagerFields() {
    return [
      DropdownButtonFormField<Departamento>(
        value: _selectedDepartamento,
        decoration: InputDecoration(
          labelText: 'Departamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.business),
        ),
        items: Departamento.values.map((dep) {
          return DropdownMenuItem(value: dep, child: Text(_enumToString(dep)));
        }).toList(),
        onChanged: (value) => setState(() => _selectedDepartamento = value!),
      ),
    ];
  }
}

// Extensão simples para meter a primeira letra maiúscula
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
