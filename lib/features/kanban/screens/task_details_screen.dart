import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/task_details_provider.dart'; // O ficheiro que editámos acima
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/core/widgets/glass_card.dart'; // O teu widget de vidro

class TaskDetailsScreen extends StatefulWidget {
  final Task? task; // Se null = Criar Nova
  final bool isReadOnly;

  const TaskDetailsScreen({super.key, this.task, required this.isReadOnly});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController;
  late TextEditingController _pointsController;

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
    _pointsController.dispose();
    super.dispose();
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
                            value: type['id'], // ou type.id se for Model
                            child: Text(type['name']), // ou type.name
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
}
