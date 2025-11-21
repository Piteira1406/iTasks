import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/task_details_provider.dart'; // O ficheiro que editámos acima
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/core/widgets/glass_card.dart'; // O teu widget de vidro
import 'package:itasks/features/kanban/providers/task_provider.dart';
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/management/task_type_management/providers/task_type_provider.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task? task; // Se null = Criar Nova
  final bool isReadOnly;

  const TaskDetailsScreen({super.key, this.task, required this.isReadOnly});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _orderController = TextEditingController();
  final _storyPointsController = TextEditingController();

  // Variáveis de estado
  int? _selectedTaskTypeId;
  int? _selectedDeveloperId;
  DateTime? _startDate;
  DateTime? _endDate;

  // Método para validar datas
  void _validateDates() {
    if (_startDate != null && _endDate != null) {
      if (_endDate!.isBefore(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data de fim deve ser posterior à data de início'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _endDate = _startDate;
        });
      }
    }
  }

  bool get _isCreating => widget.task == null;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
    _pointsController = TextEditingController();

    // Carregar dados assim que o ecrã abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TaskDetailsProvider>(context, listen: false);

      // 1. Carregar listas (devs e tipos)
      provider.loadDropdownData();

      // 2. Se for edição, preencher campos
      if (widget.task != null) {
        provider.setTaskData(widget.task!);
        _descController.text = widget.task!.description;
        _pointsController.text = widget.task!.storyPoints.toString();
      } else {
        provider.clearForm(); // Limpar se for nova
      }
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _orderController.dispose();
    _storyPointsController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = context.read<TaskDetailsProvider>();
      final authProvider = context.read<AuthProvider>();

      final managerId = authProvider.managerProfile?.id ?? 0;

      if (managerId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Gestor não identificado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Call saveTask with error callback
      final success = await taskProvider.saveTask(
        managerId,
        errorCallback: (errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return null;
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // Função para mostrar o DatePicker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    if (widget.isReadOnly) return; // Bloqueado para Programador

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      // Validate dates after setting them
      _validateDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskDetailsProvider>();
    final authProvider = context.read<AuthProvider>();
    final isEditing = widget.task != null;

    return Scaffold(
      extendBodyBehindAppBar: true, // Importante para o fundo passar por trás
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              icon: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await provider.saveTask(
                    authProvider.appUser?.id.toString() ?? 'unknown_manager',
                    existingTaskId: widget.task?.id,
                  );

                  if (success && mounted) {
                    Navigator.pop(context); // Volta para o Kanban
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao salvar ou campos inválidos'),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: Container(
        // Fundo gradiente igual ao do Kanban para consistência
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: GlassCard(
              // <--- O TEU WIDGET GLASS AQUI
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Título ---
                      Text(
                        isEditing ? "Detalhes da Tarefa" : "Criar Nova Tarefa",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Divider(color: Colors.white30),
                      const SizedBox(height: 20),

                      // --- Descrição ---
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white10,
                        ),
                        maxLines: 3,
                        enabled: !widget.isReadOnly,
                        validator: (val) => val!.isEmpty ? 'Obrigatório' : null,
                        onChanged: (val) => provider.setDescription(val),
                      ),
                      const SizedBox(height: 20),

                      // --- Story Points ---
                      TextFormField(
                        controller: _pointsController,
                        decoration: const InputDecoration(
                          labelText: 'Story Points',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white10,
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !widget.isReadOnly,
                        onChanged: (val) =>
                            provider.setStoryPoints(int.tryParse(val) ?? 0),
                      ),
                      const SizedBox(height: 20),

                      // --- Dropdown: Tipo de Tarefa ---
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Tarefa',
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(),
                        ),
                        value: provider.selectedTaskTypeId,
                        // Aqui assumimos que a lista tem Maps. Ajusta se usares Models.
                        items: provider.taskTypesList.map((type) {
                          return DropdownMenuItem<String>(
                            value: type.id, // ou type.id se for Model
                            child: Text(type.name), // ou type.name
                          );
                        }).toList(),
                        onChanged: widget.isReadOnly
                            ? null
                            : (val) => provider.setTaskTypeId(val),
                        validator: (val) =>
                            val == null ? 'Selecione um tipo' : null,
                      ),
                      const SizedBox(height: 20),

                      // --- Dropdown: Programador ---
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Atribuir a Programador',
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(),
                        ),
                        value: provider.selectedDeveloperId,
                        items: provider.developersList.map((dev) {
                          return DropdownMenuItem<String>(
                            value: dev.id.toString(),
                            child: Text(dev.name),
                          );
                        }).toList(),
                        onChanged: widget.isReadOnly
                            ? null
                            : (val) => provider.setDeveloperId(val),
                        validator: (val) =>
                            val == null ? 'Selecione um programador' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper para criar dropdown de Tipo de Tarefa
  Widget _buildTaskTypeDropdown() {
    final taskTypeProvider = context.watch<TaskTypeProvider>();
    final taskTypes = taskTypeProvider.taskTypes;

    return DropdownButtonFormField<int>(
      value: _selectedTaskTypeId,
      decoration: InputDecoration(
        labelText: 'Tipo de Tarefa',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.category),
        enabled: !widget.isReadOnly,
      ),
      items: taskTypes.map((type) {
        return DropdownMenuItem(value: type.id, child: Text(type.name));
      }).toList(),
      onChanged: widget.isReadOnly
          ? null
          : (val) {
              if (val != null) {
                setState(() {
                  _selectedTaskTypeId = val;
                });
              }
            },
      validator: (val) {
        if (!widget.isReadOnly && val == null) {
          return 'Selecione um tipo de tarefa';
        }
        return null;
      },
    );
  }

  // Helper para criar dropdown de Programador
  Widget _buildDeveloperDropdown() {
    final userManagementProvider = context.watch<UserManagementProvider>();
    final developers = userManagementProvider.developers;

    return DropdownButtonFormField<int>(
      value: _selectedDeveloperId,
      decoration: InputDecoration(
        labelText: 'Programador Responsável',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.person),
        enabled: !widget.isReadOnly,
      ),
      items: developers.map((dev) {
        return DropdownMenuItem(value: dev.id, child: Text(dev.name));
      }).toList(),
      onChanged: widget.isReadOnly
          ? null
          : (val) {
              if (val != null) {
                setState(() {
                  _selectedDeveloperId = val;
                });
              }
            },
      validator: (val) {
        if (!widget.isReadOnly && val == null) {
          return 'Selecione um programador';
        }
        return null;
      },
    );
  }

  // Helper para campos de Data
  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(BuildContext) onTap,
  ) {
    return ListTile(
      leading: Icon(Icons.calendar_today),
      title: Text(label),
      subtitle: Text(
        date == null
            ? 'Não definida'
            : '${date.day}/${date.month}/${date.year}',
      ),
      trailing: widget.isReadOnly ? null : Icon(Icons.edit),
      onTap: () => onTap(context),
    );
  }

  // Helper para campos de Datas Reais (read-only)
  Widget _buildReadOnlyField(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: TextStyle(fontSize: 16)),
    );
  }
}
