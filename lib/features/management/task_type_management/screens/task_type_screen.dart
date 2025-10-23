// features/management/task_type_management/screens/task_type_screen.dart

import 'package:flutter/material.dart';
// Importe os seus widgets visuais
// (Use o nome do seu projeto no pubspec.yaml, ex: 'itasks')
import 'package:itasks/core/widgets/glass_card.dart';
// Importe o widget de diálogo que vamos criar a seguir
import 'package:itasks/features/management/task_type_management/widgets/task_type_dialogue.dart';

class TaskTypeScreen extends StatelessWidget {
  const TaskTypeScreen({super.key});

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // O diálogo é o nosso widget personalizado
        return TaskTypeDialog(
          // TODO: Quando a lógica estiver pronta,
          // passaremos o 'taskType' para editar.
          // Por agora, é 'null' para criar um novo.
          taskType: null,
          onSave: (name) {
            // TODO: Chamar o Provider para salvar o novo tipo
            print("Salvar novo tipo: $name");
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pode usar o seu AppBar customizado aqui
      appBar: AppBar(
        title: Text('Gestão de Tipos de Tarefa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context),
        child: Icon(Icons.add),
      ),
      body:
          // TODO: Quando o Provider estiver pronto, vamos trocar este
          // Center por um Consumer que ouve o TaskTypeProvider
          // e mostra um LoadingSpinner() ou a lista.
          // Por agora, mostramos a lista "mockada" (falsa)
          _buildTaskList(context),
    );
  }

  // Este é um widget temporário para vermos a UI da lista
  Widget _buildTaskList(BuildContext context) {
    // Dados falsos para design
    final mockData = {
      'TIPO-001': 'Bug Fix',
      'TIPO-002': 'Nova Feature',
      'TIPO-003': 'Refactor',
    };

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockData.length,
      itemBuilder: (context, index) {
        final id = mockData.keys.elementAt(index);
        final name = mockData.values.elementAt(index);

        // Usamos o seu GlassCard para cada item
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            child: ListTile(
              title: Text(name),
              subtitle: Text(id),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão Editar
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white70),
                    onPressed: () {
                      // TODO: Chamar _showEditDialog com os dados
                      print("Editar $name");
                    },
                  ),
                  // Botão Apagar
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      // TODO: Chamar o Provider para apagar
                      print("Apagar $name");
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
