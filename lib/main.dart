// lib/main.dart (Atualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart'; // <--- NOVO
// ... (Outros imports)

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // <--- Adicionar ThemeProvider
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
    final themeProvider = Provider.of<ThemeProvider>(context); // <--- OBTEM O TEMA

    return MaterialApp(
      title: 'iTasks',
      debugShowCheckedModeBanner: false,
      
      // Aplicar os temas com base no estado do ThemeProvider
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // <--- Aplica o tema atual

      home: authProvider.isLoggedIn 
          ? const KanbanScreen() 
          : const LoginScreen(),
      // ... (Rotas)
    );
  }
}