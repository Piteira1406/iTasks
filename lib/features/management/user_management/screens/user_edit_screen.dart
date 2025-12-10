import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/core/widgets/custom_snackbar.dart';

import 'package:itasks/core/models/app_user_model.dart';
import 'package:itasks/core/models/manager_model.dart';
import 'package:itasks/core/models/developer_model.dart';
import 'package:itasks/core/services/firestore_service.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';

// Constantes baseadas no enunciado
enum UserRole { programador, manager }

enum NivelExperiencia { junior, pleno, senior }

enum Departamento { mobile, web, qa, design }

class UserEditScreen extends StatefulWidget {
  final AppUser? user; // Se null, é criação. Se não, é edição.

  const UserEditScreen({super.key, this.user});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.programador;
  NivelExperiencia _selectedNivel = NivelExperiencia.junior;
  Departamento _selectedDepartamento = Departamento.mobile;
  int? _selectedManagerId;

  Manager? _originalManager;
  Developer? _originalDeveloper;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userManagementProvider = context.read<UserManagementProvider>();

      userManagementProvider.fetchManagers();

      if (_isEditing) {
      if (_isEditing) {
        await _loadUserProfileData();
      }
    });

    if (_isEditing) {
      _nameController.text = widget.user!.name;
      _usernameController.text = widget.user!.username;

      if (widget.user!.type == 'Manager') {
        _selectedRole = UserRole.manager;
      } else {
        _selectedRole = UserRole.programador;
      }
    }
  }

  Future<void> _loadUserProfileData() async {
    if (!_isEditing) return;

    final firestoreService = context.read<FirestoreService>();
    
    if (widget.user!.type == 'Manager') {
      final manager = await firestoreService.getManagerByUserId(widget.user!.uid);
      
      if (manager != null && mounted) {
        setState(() {
          _originalManager = manager; // Preservar objeto original com docId
          
          // Converter string do departamento para enum
          try {
            _selectedDepartamento = Departamento.values.firstWhere(
              (d) => d.name == manager.department,
              orElse: () => Departamento.mobile,
            );
          } catch (e) {
            _selectedDepartamento = Departamento.mobile;
          }
        });
      }
    } else {
      final developer = await firestoreService.getDeveloperByUserId(widget.user!.uid);
      
      if (developer != null && mounted) {
        setState(() {
          _originalDeveloper = developer; // Preservar objeto original com docId
          _selectedManagerId = developer.idManager;
          
          // Converter string do nível para enum
          try {
            _selectedNivel = NivelExperiencia.values.firstWhere(
              (n) => n.name == developer.experienceLevel,
              orElse: () => NivelExperiencia.junior,
            );
          } catch (e) {
            _selectedNivel = NivelExperiencia.junior;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final userManagementProvider = context.read<UserManagementProvider>();

      if (_isEditing) {
        final appUser = AppUser(
          id: widget.user!.id,
          uid: widget.user!.uid,
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _usernameController.text.trim(),
          type: _selectedRole == UserRole.manager ? 'Manager' : 'Developer',
        );

        Manager? manager;
        Developer? developer;

        if (_selectedRole == UserRole.manager) {
          manager = Manager(
            id: widget.user!.id, // Usar o mesmo ID
            name: _nameController.text.trim(),
            department: _selectedDepartamento.name,
            idUser: widget.user!.id,
            docId: _originalManager?.docId, // Preservar docId original
          );
        } else {
          developer = Developer(
            id: widget.user!.id, // Usar o mesmo ID
            name: _nameController.text.trim(),
            experienceLevel: _selectedNivel.name,
            idUser: widget.user!.id,
            idManager: _selectedManagerId ?? 0,
            docId: _originalDeveloper?.docId, // Preservar docId original
          );
        }

        // Call Provider to update
        final String? error = await userManagementProvider.updateUser(
          uid: widget.user!.uid,
          appUser: appUser,
          manager: manager,
          developer: developer,
        );

        if (error != null) {
          if (mounted) {
            CustomSnackBar.showError(context, error);
          }
        } else {
          if (mounted) {
            CustomSnackBar.showSuccess(context, 'Utilizador atualizado com sucesso!');
            Navigator.of(context).pop();
          }
        }
      } else {
        final appUser = AppUser(
          id: 0, // Will be generated by Provider
          uid: '', // Will be set by Firebase Auth during creation
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _usernameController.text.trim(),
          type: _selectedRole == UserRole.manager ? 'Manager' : 'Developer',
        );

        Manager? manager;
        Developer? developer;

        if (_selectedRole == UserRole.manager) {
          manager = Manager(
            id: 0, // Will be generated by Provider
            name: _nameController.text.trim(),
            department: _selectedDepartamento.name,
            idUser: 0, // Will be set by Provider
          );
        } else {
          developer = Developer(
            id: 0, // Will be generated by Provider
            name: _nameController.text.trim(),
            experienceLevel: _selectedNivel.name,
            idUser: 0, // Will be set by Provider
            idManager: _selectedManagerId ?? 0,
          );
        }

        // Call Provider to save
        final String? error = await userManagementProvider.createNewUser(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
          appUser: appUser,
          manager: manager,
          developer: developer,
        );

        if (error != null) {
          // Show error message
          if (mounted) {
            CustomSnackBar.showError(context, error);
          }
        } else {
          // Success
          if (mounted) {
            CustomSnackBar.showSuccess(context, 'Utilizador criado com sucesso!');
            Navigator.of(context).pop();
          }
        }
      }
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                if (!_isEditing) ...[
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock,
                    obscureText: true,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (val.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Para alterar password: utilizador deve fazer logout e usar '
                            '"Esqueci a password" no ecrã de login.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // --- Campos Condicionais ---
                if (_selectedRole == UserRole.programador)
                  ..._buildDeveloperFields(provider),
                if (_selectedRole == UserRole.manager) ..._buildManagerFields(),

                const SizedBox(height: 32),
                CustomButton(text: 'Salvar', onPressed: _saveForm),
                const SizedBox(height: 24), // Extra bottom padding
              ],
            ],
          ),
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
        return DropdownMenuItem(
          value: role,
          child: Text(role.name.capitalize()),
        );
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
    // FILTRO REAL: Buscar apenas quem é 'Manager' na lista de users
    final managersList = provider.users
        .where((u) => u.type == 'Manager')
        .toList();

    return [
      DropdownButtonFormField<NivelExperiencia>(
        value: _selectedNivel,
        decoration: InputDecoration(
          labelText: 'Nível de Experiência *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.star_border),
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

      // DROPDOWN REAL DE GESTORES
      DropdownButtonFormField<int>(
        initialValue: _selectedManagerId,
        hint: const Text('Selecionar Gestor'),
        decoration: InputDecoration(
          labelText: 'Gestor Responsável',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.supervisor_account),
        ),
        items: managersList
            .map(
              (manager) => DropdownMenuItem<int>(
                value: manager.id,
                child: Text(manager.name),
              ),
            )
            .toList(),
        onChanged: (int? value) {
          setState(() => _selectedManagerId = value);
        },
        validator: (value) {
          if (value == null) {
            return 'Selecione um gestor';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildManagerFields() {
    return [
      DropdownButtonFormField<Departamento>(
        value: _selectedDepartamento,
        decoration: InputDecoration(
          labelText: 'Departamento *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.business),
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

// Extensão simples para meter a primeira letra maiúscula
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
