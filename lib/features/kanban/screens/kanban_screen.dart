import 'dart:ui'; // Para o BackdropFilter (efeito Glass)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'package:itasks/core/models/task_model.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
import 'package:itasks/features/kanban/widgets/kanban_card_widget.dart';
import 'package:itasks/core/providers/auth_provider.dart'; // <-- Importar o AuthProvider

// TODO: Importar o provider do Tema (ex: ThemeProvider)

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
    // Usamos listen: false aqui porque estamos fora do método build
    Provider.of<KanbanProvider>(context, listen: false).fetchTasks();
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
        // 1. Estado de Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Construção das 3 listas (ToDo, Doing, Done)
        // O provider já nos dá as listas filtradas e ordenadas
        final List<DragAndDropList> kanbanLists = [
          _buildDragList(context, "A Fazer", provider.todoTasks),
          _buildDragList(context, "Em Execução", provider.doingTasks),
          _buildDragList(context, "Concluído", provider.doneTasks),
        ];

        // 3. O widget principal do DragAndDropLists
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
                // (O 'listHeaderDecoration' foi movido para o _buildDragList)

                // --- A LÓGICA PRINCIPAL ---
                onItemReorder:
                    (
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
    // --- INÍCIO DAS CORREÇÕES (da imagem image_ac51a6.png) ---

    // 1. Precisamos do AuthProvider para saber o tipo de utilizador
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 2. Definimos a lógica do isReadOnly
    final bool isReadOnly = (authProvider.appUser?.type == 'Programador');

    return DragAndDropList(
      // 3. (CORREÇÃO do erro 'listHeaderDecoration')
      // O nome correto é 'headerDecoration' e fica aqui.

      // --- FIM DAS CORREÇÕES ---

      // Header (Título da coluna)
      header: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "$title (${tasks.length})", // Mostra o contador de tarefas
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      // Itens (os cartões)
      children: tasks.map((task) {
        return DragAndDropItem(
          // O widget do cartão
          child: KanbanCardWidget(
            // 4. (CORREÇÃO do erro 'key')
            // A 'key' deve estar no widget do cartão
            key: ValueKey(task.id),

            // 5. (CORREÇÃO do erro 'isReadOnly')
            // Passamos a variável que definimos em cima
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
    // O "Auth" é só para o botão de Logout
    final authProvider = context.watch<AuthProvider>();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Drawer(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor.withOpacity(0.7),
          elevation: 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
                child: Text(
                  'Menu (${authProvider.appUser?.name ?? "Utilizador"})', // Mostra o nome do user
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // O Botão de Toggle (mudar tema)
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
                  leading: const Icon(Icons.settings),
                  title: const Text('Tipos de Tarefa'),
                  onTap: () {
                    Navigator.of(context).pop(); // Fecha o drawer
                    // TODO: Navigator.pushNamed(context, '/task_types');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Gestão de Utilizadores'),
                  onTap: () {
                    Navigator.of(context).pop(); // Fecha o drawer
                    // TODO: Navigator.pushNamed(context, '/user_list');
                  },
                ),
                const Divider(),
              ],
              // TODO: Adicionar os Relatórios
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red.shade400),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red.shade400),
                ),
                onTap: () {
                  context.read<AuthProvider>().signOut();
                  Navigator.of(context).pop(); // Fecha o drawer
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
