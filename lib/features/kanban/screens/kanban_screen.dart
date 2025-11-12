// lib/features/kanban/screens/kanban_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itasks/features/kanban/providers/kanban_provider.dart';
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
    // Fetch tasks when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KanbanProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kanbanProvider = context.watch<KanbanProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('iTasks - ${authProvider.appUser?.name ?? ""}'),
        actions: [
          // Theme toggle
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              // Toggle theme
            },
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.signOut();
            },
          ),
        ],
      ),
      body: kanbanProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Error message banner
                if (kanbanProvider.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red,
                    child: Text(
                      kanbanProvider.errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Kanban board
                Expanded(
                  child: Row(
                    children: [
                      // ToDo column
                      Expanded(
                        child: _buildColumn(
                          context,
                          'To Do',
                          kanbanProvider.todoTasks,
                          0,
                        ),
                      ),
                      // Doing column
                      Expanded(
                        child: _buildColumn(
                          context,
                          'Doing',
                          kanbanProvider.doingTasks,
                          1,
                        ),
                      ),
                      // Done column
                      Expanded(
                        child: _buildColumn(
                          context,
                          'Done',
                          kanbanProvider.doneTasks,
                          2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: authProvider.isManager
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to create task screen
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildColumn(
    BuildContext context,
    String title,
    List tasks,
    int columnIndex,
  ) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(task.description),
                    subtitle: Text('Order: ${task.order}'),
                    onTap: () {
                      // Navigate to task details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
