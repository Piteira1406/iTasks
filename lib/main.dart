import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// --- CORE ---
// Serviços
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/csv_service.dart';

// Providers Core
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

// --- FEATURES ---
// Providers das Features
import 'features/kanban/providers/kanban_provider.dart';
import 'features/kanban/providers/task_provider.dart';
import 'features/management/user_management/providers/user_management_provider.dart';
import 'features/management/task_type_management/providers/task_type_provider.dart';
import 'features/reports/providers/report_provider.dart';

// Ecrãs
import 'features/auth/screens/login_screen.dart';
import 'features/kanban/screens/kanban_screen.dart';

// Ponto de entrada da aplicação
Future<void> main() async {
  // 1. Garantir que o Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar o Firebase (OBRIGATÓRIO)
  await Firebase.initializeApp(
    // Se estiver a usar o FlutterFire CLI, descomente a linha abaixo
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Instanciar os seus serviços (singletons)
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  final CsvService csvService = CsvService();

  // 4. Correr a aplicação com os Providers
  runApp(
    MultiProvider(
      providers: [
        // --- PROVIDERS CORE ---
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // --- PROVIDERS DAS FEATURES ---
        ChangeNotifierProvider(create: (_) => KanbanProvider(firestoreService)),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(firestoreService, authService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskTypeProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(firestoreService, csvService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskDetailsProvider(firestoreService),
        ),
      ],
      child: const iTasksApp(),
    ),
  );
}

// Widget Raiz da Aplicação
class iTasksApp extends StatelessWidget {
  const iTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ouve o ThemeProvider
    // (context.watch<T>() é a forma moderna de Provider.of<T>(context))
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'iTasks',
      debugShowCheckedModeBanner: false,

      // Aplicar os temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // AuthWrapper decide qual o primeiro ecrã a mostrar
      home: const AuthWrapper(),

      // TODO: Adicionar aqui as suas rotas nomeadas se necessário
    );
  }
}

// Este widget "ouve" o AuthProvider e mostra o ecrã correto.
// Substitui a lógica que tinha em 'home:' para também
// mostrar um ecrã de loading.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Ouve o AuthProvider
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const KanbanScreen(); // Logado -> Vai para o Kanban
      case AuthStatus.unauthenticated:
        return const LoginScreen(); // Não logado -> Vai para o Login
      case AuthStatus.uninitialized:
        // A verificar... -> Mostra um ecrã de loading
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
