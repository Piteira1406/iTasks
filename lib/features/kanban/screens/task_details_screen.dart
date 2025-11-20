// features/kanban/screens/task_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importe os seus widgets
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/features/kanban/providers/task_provider.dart';
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/management/task_type_management/providers/task_type_provider.dart';
import 'package:itasks/features/management/user_management/providers/user_management_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final dynamic
  task; // Tarefa (mockada) para editar/ver. Se for 'null', é para criar.
  final bool
  isReadOnly; // Se 'true', bloqueia todos os campos (modo Programador)

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
    if (!_isCreating) {
      // Se estamos a editar/ver, preenchemos os campos
      _titleController.text = widget.task['title'];
      _orderController.text = widget.task['order'].toString();
      // TODO: Preencher o resto (desc, datas, dropdowns)
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    String title = _isCreating
        ? 'Nova Tarefa'
        : (widget.isReadOnly ? 'Detalhes da Tarefa' : 'Editar Tarefa');

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campos Editáveis pelo Gestor ---
              CustomTextField(
                controller: _titleController,
                hintText: 'Título da Tarefa',
                icon: Icons.title,
                readOnly: widget.isReadOnly,
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                hintText: 'Descrição',
                icon: Icons.description,
                readOnly: widget.isReadOnly,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  if (value.trim().length < 10) {
                    return 'Descrição deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown Tipo de Tarefa
              _buildTaskTypeDropdown(),
              const SizedBox(height: 16),
              // Dropdown Programador
              _buildDeveloperDropdown(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _orderController,
                hintText: 'Ordem de Execução',
                icon: Icons.priority_high,
                readOnly: widget.isReadOnly,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ordem é obrigatória';
                  }
                  final order = int.tryParse(value);
                  if (order == null || order <= 0) {
                    return 'Ordem deve ser um número maior que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _storyPointsController,
                hintText: 'Story Points (estimativa de complexidade)',
                icon: Icons.stars,
                readOnly: widget.isReadOnly,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Story Points é obrigatório';
                  }
                  final points = int.tryParse(value);
                  if (points == null || points <= 0) {
                    return 'Story Points deve ser maior que 0';
                  }
                  if (points > 100) {
                    return 'Story Points deve ser no máximo 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- Datas Previstas ---
              Text(
                'Datas Previstas',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              _buildDatePicker(
                'Data Início Prevista',
                _startDate,
                (ctx) => _selectDate(ctx, true),
              ),
              _buildDatePicker(
                'Data Fim Prevista',
                _endDate,
                (ctx) => _selectDate(ctx, false),
              ),

              const SizedBox(height: 24),

              // --- Datas Reais (Apenas Leitura) ---
              if (!_isCreating) ...[
                Text(
                  'Datas Reais (Automático)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                _buildReadOnlyField(
                  'Início Real:',
                  '2025-10-22',
                ), // TODO: vir do 'task'
                _buildReadOnlyField(
                  'Fim Real:',
                  'Ainda não concluído',
                ), // TODO: vir do 'task'
                const SizedBox(height: 24),
              ],

              // Botão de Salvar (só aparece se não for ReadOnly)
              if (!widget.isReadOnly)
                CustomButton(text: 'Salvar Tarefa', onPressed: _saveForm),
            ],
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
        return DropdownMenuItem(
          value: type.id,
          child: Text(type.name),
        );
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
        return DropdownMenuItem(
          value: dev.id,
          child: Text(dev.name),
        );
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
