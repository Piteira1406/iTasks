// features/management/task_type_management/widgets/task_type_dialog.dart

import 'package:flutter/material.dart';
// Importe os seus widgets visuais
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/custom_textfield.dart';
// TODO: Quando o modelo estiver pronto, importe-o
// import 'package:itasks/core/models/task_type_model.dart';

class TaskTypeDialog extends StatefulWidget {
  // Se 'taskType' for null, é para criar.
  // Se for preenchido, é para editar.
  // final TaskTypeModel? taskType; // TODO: Descomentar quando o modelo existir
  final dynamic taskType; // Temporário

  final Function(String name) onSave;

  const TaskTypeDialog({super.key, this.taskType, required this.onSave});

  @override
  State<TaskTypeDialog> createState() => _TaskTypeDialogState();
}

class _TaskTypeDialogState extends State<TaskTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Descomentar isto quando o modelo estiver pronto
    // if (widget.taskType != null) {
    //   _nameController.text = widget.taskType!.name;
    // }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskType != null;

    // Usamos um AlertDialog com o fundo transparente
    // para que o nosso GlassCard seja a base.
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: GlassCard(
        // O seu widget de vidro
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Editar Tipo de Tarefa' : 'Novo Tipo de Tarefa',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Nome do Tipo (ex: Bug, Feature)',
                  icon: Icons.label,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome é obrigatório.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(text: 'Salvar', onPressed: _submit),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
