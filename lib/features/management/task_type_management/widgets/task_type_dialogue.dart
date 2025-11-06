// features/management/task_type_management/widgets/task_type_dialog.dart

import 'package:flutter/material.dart';
// Importe os seus widgets visuais
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/custom_text_field.dart';
import 'package:itasks/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:itasks/core/models/task_type_model.dart';
import 'package:itasks/core/widgets/loading_spinner.dart';

class TaskTypeDialog extends StatefulWidget {
  // Usa o modelo real. 'null' se for para criar um novo.
  final TaskTypeModel? taskType;
  // Função 'onSave' que devolve o nome escrito
  final Function(String name) onSave;

  const TaskTypeDialog({super.key, this.taskType, required this.onSave});

  @override
  State<TaskTypeDialog> createState() => _TaskTypeDialogState();
}

class _TaskTypeDialogState extends State<TaskTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Se estiver a editar, preenche o campo com o nome antigo
    _nameController = TextEditingController(text: widget.taskType?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Chama a função onSave (que foi passada pelo 'TaskTypeScreen')
      // e passa-lhe o novo nome
      await widget.onSave(_nameController.text.trim());

      // (Não precisamos de setState(false) se o widget for fechar)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determina se estamos a Criar ou a Editar
    final isEditing = widget.taskType != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Editar Tipo de Tarefa' : 'Novo Tipo de Tarefa',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Nome (ex: Bug, Feature, Setup)',
                  icon: Icons.label_outline,
                  validator: (val) =>
                      val!.isEmpty ? 'Por favor, insira um nome' : null,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const LoadingSpinner()
                else
                  CustomButton(
                    text: isEditing ? 'Salvar Alterações' : 'Criar',
                    onPressed: _submit,
                  ),
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
