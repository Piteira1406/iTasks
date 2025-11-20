import 'dart:ui'; // Para o BackdropFilter (efeito Glass)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/features/kanban/widgets/kanban_card_widget.dart';
import 'package:itasks/core/providers/auth_provider.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia o carregamento das tarefas assim que o ecrã é construído
    // Usar addPostFrameCallback para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KanbanProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparência para o efeito "Glass" funcionar no Drawer
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('iTasks Kanban'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () {
              // Navigate to create task
              Navigator.pushNamed(context, '/task_details');
            },
            tooltip: 'Nova Tarefa',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<KanbanProvider>().fetchTasks();
            },
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: _buildGlassDrawer(context), // O Menu lateral
      body: _buildKanbanBody(),
    );
  }

  /// Constrói o corpo principal do Kanban
  Widget _buildKanbanBody() {
    // O Consumer reage às mudanças no KanbanProvider (loading, listas, erros)
    return Consumer<KanbanProvider>(
      builder: (context, provider, child) {
        // 1. Better error handling - show error UI if there's an error
        if (provider.errorMessage.isNotEmpty && 
            provider.todoTasks.isEmpty && 
            provider.doingTasks.isEmpty && 
            provider.doneTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar tarefas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.fetchTasks();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Log error details for debugging
                    print('Error details: ${provider.errorMessage}');
                  },
                  child: const Text('Ver Detalhes do Erro'),
                ),
              ],
            ),
          );
        }

        // 2. Better loading state - show loading indicator with text
        if (provider.isLoading && 
            provider.todoTasks.isEmpty && 
            provider.doingTasks.isEmpty && 
            provider.doneTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'A carregar tarefas...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        // 3. Empty state - show helpful message when no tasks exist
        if (provider.todoTasks.isEmpty &&
            provider.doingTasks.isEmpty &&
            provider.doneTasks.isEmpty &&
            !provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma tarefa encontrada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie a primeira tarefa para começar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/task_details');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Tarefa'),
                ),
              ],
            ),
          );
        }

        // 4. Construção das 3 listas (ToDo, Doing, Done)
        final List<DragAndDropList> kanbanLists = [
          _buildDragList(context, "A Fazer", provider.todoTasks),
          _buildDragList(context, "Em Execução", provider.doingTasks),
          _buildDragList(context, "Concluído", provider.doneTasks),
        ];

        // 5. O widget principal do DragAndDropLists
        return Column(
          children: [
            // Área para mostrar erros temporários (das regras de negócio)
            if (provider.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.red.withOpacity(0.9),
                padding: const EdgeInsets.all(10),
                child: Text(
                  provider.errorMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // O "Board"
            Expanded(
              child: DragAndDropLists(
                children: kanbanLists,

                // --- Configuração Visual ---
                axis: Axis.horizontal, // Scroll horizontal
                listWidth: 320, // Largura de cada coluna
                listDraggingWidth: 320, // Largura ao arrastar
                listPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),

                // --- Decoração das Colunas ---
                listDecoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),

                // --- A LÓGICA PRINCIPAL ---
                onItemReorder: (
                  int oldItemIndex,
                  int oldListIndex,
                  int newItemIndex,
                  int newListIndex,
                ) {
                  provider.handleTaskMove(
                    oldItemIndex,
                    oldListIndex,
                    newItemIndex,
                    newListIndex,
                  );
                },

                // Não precisamos disto (reordenar colunas)
                onListReorder: (int oldListIndex, int newListIndex) {
                  // Não faz nada
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Helper para construir uma coluna (DragAndDropList)
  DragAndDropList _buildDragList(
    BuildContext context,
    String title,
    List<Task> tasks,
  ) {
    // Precisamos do AuthProvider para saber o tipo de utilizador
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Definimos a lógica do isReadOnly
    final bool isReadOnly = (authProvider.appUser?.type == 'Developer');

    return DragAndDropList(
      // Header (Título da coluna)
      header: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "$title (${tasks.length})", // Mostra o contador de tarefas
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),

      // Itens (os cartões)
      children: tasks.map((task) {
        return DragAndDropItem(
          // O widget do cartão
          child: KanbanCardWidget(
            key: ValueKey(task.id),
            isReadOnly: isReadOnly,
            task: task,
          ),

          // Regra de UI: Não permite arrastar cartões "Concluídos"
          canDrag: task.taskStatus != 'Done',
        );
      }).toList(),
    );
  }

  /// O Menu Lateral com efeito "Glass"
  Widget _buildGlassDrawer(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Drawer(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
          elevation: 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                child: Text(
                  'Menu (${authProvider.appUser?.name ?? "Utilizador"})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ✅ Item do Kanban (tela atual)
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Kanban Board'),
                selected: true, // Destaca que é a tela atual
                onTap: () {
                  Navigator.of(context).pop(); // Só fecha o drawer
                },
              ),

              const Divider(),

              // ✅ Link para Relatórios
              ListTile(
                leading: const Icon(Icons.analytics),
                title: const Text('Relatórios'),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o drawer
                  Navigator.pushNamed(context, '/reports'); // Navega para Reports
                },
              ),

              const Divider(),

              // Botão de Toggle (mudar tema)
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Mudar Tema'),
                trailing: Switch(
                  value: false, // TODO: Ligar ao ThemeProvider
                  onChanged: (val) {
                    // TODO: Chamar o provider
                    // context.read<ThemeProvider>().toggleTheme();
                  },
                ),
              ),

              const Divider(),

              // Só mostra estes menus se for Manager
              if (authProvider.appUser?.type == 'Manager') ...[
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Tipos de Tarefa'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/task_types');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Gestão de Utilizadores'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/user_management');
                  },
                ),
                const Divider(),
              ],

              // Logout
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red.shade400),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}