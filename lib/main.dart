// lib/main.dart (Atualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart'; // <--- NOVO
// ... (Outros imports)
// Imports para os seus ficheiros

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/kanban/screens/kanban_screen.dart';

// Provavelmente também vai precisar dos seus serviços aqui
// para os fornecer ao MultiProvider
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';

import 'package:itasks/features/management/task_type_management/screens/task_type_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // <--- Adicionar ThemeProvider
        // ... (Outros Providers)
      ],
      child: const iTasksApp(),
    ),
  );
}

class iTasksApp extends StatelessWidget {
  const iTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(
      context,
    ); // <--- OBTEM O TEMA

    return MaterialApp(
      title: 'iTasks',
      debugShowCheckedModeBanner: false,

      // Aplicar os temas com base no estado do ThemeProvider
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // <--- Aplica o tema atual

      home: authProvider.isLoggedIn
          ? const KanbanScreen()
          : const LoginScreen(), // ... (Rotas)
    );
  }
}
