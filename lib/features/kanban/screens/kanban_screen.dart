import 'dart:ui'; // Para o ImageFilter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart'; // O pacote novo

import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/features/kanban/widgets/kanban_card_widget.dart';
import 'package:itasks/core/providers/auth_provider.dart';
import 'package:itasks/features/kanban/screens/task_details_screen.dart';
import 'package:itasks/core/providers/theme_provider.dart'; // <--- 1. ADICIONADO

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as tarefas ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KanbanProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRÍTICO PARA O DRAWER GLASS: O corpo estende-se para trás da AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('iTasks Kanban'),
        backgroundColor: Colors.transparent, // AppBar transparente
        elevation: 0,
        actions: [
          // Botão para CRIAR NOVA TAREFA (+)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Passamos task: null para indicar que é uma NOVA tarefa
                  builder: (context) =>
                      const TaskDetailsScreen(task: null, isReadOnly: false),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildGlassDrawer(context), // <--- 2. O DRAWER ATUALIZADO
      body: Container(
        // Fundo geral da app (gradiente ou cor sólida) para o vidro sobressair
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
        child: SafeArea(child: _buildKanbanBody()),
      ),
    );
  }

  Widget _buildKanbanBody() {
    return Consumer<KanbanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<DragAndDropList> kanbanLists = [
          _buildDragList(context, "A Fazer", provider.todoTasks),
          _buildDragList(context, "Em Execução", provider.doingTasks),
          _buildDragList(context, "Concluído", provider.doneTasks),
        ];

        return Column(
          children: [
            if (provider.errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.red.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(10),
                child: Text(
                  provider.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Expanded(
              child: DragAndDropLists(
                children: kanbanLists,
                axis: Axis.horizontal,
                listWidth: 340, // Colunas ligeiramente mais largas
                listDraggingWidth: 340,
                listPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                // Removemos decorações globais para personalizar cada lista
                onItemReorder: (oldItem, oldList, newItem, newList) {
                  provider.handleTaskMove(oldItem, oldList, newItem, newList);
                },
                onListReorder: (_, __) {},
              ),
            ),
          ],
        );
      },
    );
  }

  /// Reconstrói o cabeçalho com efeito Glass manual
  DragAndDropList _buildDragList(
    BuildContext context,
    String title,
    List<Task> tasks,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isReadOnly = (authProvider.appUser?.type == 'Programador');

    return DragAndDropList(
      // AQUI ESTÁ O TRUQUE: O Header é um Container com estilo Glass
      header: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(
          bottom: 8,
        ), // Espaço entre titulo e cartões
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).cardColor.withValues(alpha: 0.6), // Vidro fosco
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${tasks.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      children: tasks.map((task) {
        return DragAndDropItem(
          child: KanbanCardWidget(
            key: ValueKey(task.id),
            task: task,
            isReadOnly: isReadOnly,
          ),
          canDrag: task.taskStatus != 'Done',
        );
      }).toList(),
    );
  }

  /// 3. DRAWER ATUALIZADO (COM TEMA E NAVEGAÇÃO)
  Widget _buildGlassDrawer(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Agora usamos o ThemeProvider real para controlar o switch
    final themeProvider = context.watch<ThemeProvider>();

    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent, // Fundo transparente para o blur
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // Blur forte
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withValues(
                alpha: 0.8,
              ), // Cor base semi-transparente
              border: Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // --- CABEÇALHO ---
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person, size: 35),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        authProvider.appUser?.name ?? "Utilizador",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // Forçamos branco para contraste no header colorido
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        authProvider.appUser?.type ?? "Convidado",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- TOGGLE DO TEMA ---
                ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text('Modo Escuro/Claro'),
                  trailing: Switch(
                    // Liga o valor ao estado real do provider
                    value: themeProvider.isDarkMode,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (val) {
                      // Chama a função de toggle
                      themeProvider.toggleTheme(val);
                    },
                  ),
                ),
                const Divider(),

                // --- NAVEGAÇÃO (Só Manager) ---
                if (authProvider.appUser?.type == 'Manager') ...[
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Tipos de Tarefa'),
                    onTap: () {
                      Navigator.pop(context); // Fecha drawer
                      // Certifica-te que a rota '/task_types' existe no main.dart
                      Navigator.pushNamed(context, '/task_types');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Utilizadores'),
                    onTap: () {
                      Navigator.pop(context);
                      // Certifica-te que a rota '/users' existe no main.dart
                      Navigator.pushNamed(context, '/users');
                    },
                  ),
                ],
                const Divider(),

                // --- LOGOUT ---
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.signOut();
                    // O AuthWrapper trata do resto
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
