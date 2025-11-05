// features/kanban/screens/task_details_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';

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

  // TODO: Estes dados (tipos, devs) devem vir dos Providers
  final _mockTaskTypes = {'type1': 'Bug Fix', 'type2': 'Feature'};
  final _mockDevelopers = {'dev1': 'Bruno Costa', 'dev2': 'Carla Dias'};

  // Variáveis de estado
  String? _selectedTaskTypeId;
  String? _selectedDeveloperId;
  DateTime? _startDate;
  DateTime? _endDate;

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
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Chamar o Provider para salvar a tarefa
      print("A salvar tarefa...");
      Navigator.of(context).pop();
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
              ),
              const SizedBox(height: 16),
              // Dropdown Tipo de Tarefa
              _buildDropdown(
                label: 'Tipo de Tarefa',
                icon: Icons.label,
                value: _selectedTaskTypeId,
                items: _mockTaskTypes,
                onChanged: (val) => setState(() => _selectedTaskTypeId = val),
              ),
              const SizedBox(height: 16),
              // Dropdown Programador
              _buildDropdown(
                label: 'Atribuir a Programador',
                icon: Icons.person,
                value: _selectedDeveloperId,
                items: _mockDevelopers,
                onChanged: (val) => setState(() => _selectedDeveloperId = val),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _orderController,
                hintText: 'Ordem de Execução',
                icon: Icons.priority_high,
                readOnly: widget.isReadOnly,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Campo obrigatório' : null,
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

  // Helper para criar Dropdowns
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      items: items.entries.map((entry) {
        return DropdownMenuItem(value: entry.key, child: Text(entry.value));
      }).toList(),
      onChanged: widget.isReadOnly ? null : onChanged, // Bloqueado se ReadOnly
      validator: (val) => val == null ? 'Campo obrigatório' : null,
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
