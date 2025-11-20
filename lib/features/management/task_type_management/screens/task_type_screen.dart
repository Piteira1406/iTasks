// features/management/task_type_management/screens/task_type_screen.dart

import 'package:flutter/material.dart';
import 'package:itasks/core/widgets/glass_card.dart';
import 'package:itasks/core/widgets/loading_spinner.dart';
import 'package:itasks/features/management/task_type_management/widgets/task_type_dialogue.dart';
// --- Imports Novos ---
import 'package:provider/provider.dart';
import 'package:itasks/features/management/task_type_management/providers/task_type_provider.dart';
import 'package:itasks/core/models/task_type_model.dart'; // Modelo real

class TaskTypeScreen extends StatefulWidget {
  const TaskTypeScreen({super.key});

  @override
  State<TaskTypeScreen> createState() => _TaskTypeScreenState();
}

class _TaskTypeScreenState extends State<TaskTypeScreen> {
  @override
  void initState() {
    super.initState();
    // Pede ao Provider para ir buscar os dados assim que o ecrã é construído
    // Usamos addPostFrameCallback para garantir que o 'context' está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos 'context.read' porque não queremos "ouvir" mudanças aqui.
      // O 'Consumer' no 'build' tratará disso.
      context.read<TaskTypeProvider>().fetchTaskTypes();
    });
  }

  // Função do Pop-up (agora usa o Provider)
  void _showEditDialog(BuildContext context, {TaskTypeModel? taskType}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return TaskTypeDialog(
          taskType: taskType, // Passa o tipo de tarefa (null se for para criar)
          onSave: (name) async {
            // Usa o Provider para salvar
            // Usamos 'context.read' porque estamos dentro de uma função
            final provider = context.read<TaskTypeProvider>();
            bool success = await provider.saveTaskType(
              existingTaskType: taskType,
              name: name,
            );

            if (success && mounted) {
              Navigator.of(dialogContext).pop(); // Fecha o pop-up
            }
            // Se falhar, o provider vai mostrar um erro (que podemos adicionar à UI)
          },
        );
      },
    );
  }

  // Função de Apagar (agora usa o Provider)
  void _deleteType(TaskTypeModel taskType) {
    // TODO: Mostrar um diálogo de confirmação "Tem a certeza?"

    // Usa o Provider para apagar
    context.read<TaskTypeProvider>().deleteTaskType(taskType.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestão de Tipos de Tarefa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showEditDialog(context), // Criar novo (taskType: null)
        child: Icon(Icons.add),
      ),
      body:
          // Usa o Consumer para "ouvir" as mudanças do Provider
          Consumer<TaskTypeProvider>(
            builder: (context, provider, child) {
              // 1. Estado de Loading
              // (Verificamos o loading *depois* de buscar a lista,
              // para o loading de apagar/editar não piscar o ecrã todo)
              final taskTypes = provider.taskTypes;

              if (taskTypes.isEmpty &&
                  provider.state == TaskTypeState.loading) {
                return const LoadingSpinner();
              }

              // 2. Estado de Erro
              if (provider.state == TaskTypeState.error) {
                return Center(child: Text('Erro: ${provider.errorMessage}'));
              }

              // 3. Estado Sucesso (Vazio)
              if (taskTypes.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum tipo de tarefa encontrado.\nClique no "+" para adicionar um.',
                  ),
                );
              }

              // 4. Constrói a lista real
              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: taskTypes.length,
                    itemBuilder: (context, index) {
                      final task = taskTypes[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          child: ListTile(
                            title: Text(task.name),
                            subtitle: Text(
                              task.id.toString(),
                            ), // Mostra o ID real do Firestore
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Botão Editar
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white70),
                                  onPressed: () => _showEditDialog(
                                    context,
                                    taskType: task,
                                  ), // Editar
                                ),
                                // Botão Apagar
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => _deleteType(task), // Apagar
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Mostra um spinner por cima da lista se estiver a apagar/editar
                  if (provider.state == TaskTypeState.loading)
                    const LoadingSpinner(),
                ],
              );
            },
          ),
    );
  }
}
