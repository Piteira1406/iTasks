import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ficheiro gerado pelo 'flutterfire configure'

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
import 'features/kanban/providers/task_details_provider.dart';
import 'features/management/user_management/providers/user_management_provider.dart';
import 'features/management/task_type_management/providers/task_type_provider.dart';
import 'features/reports/providers/report_provider.dart';

// Ecrãs
import 'features/auth/screens/login_screen.dart';
import 'features/kanban/screens/kanban_screen.dart';
import 'features/kanban/screens/task_details_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/management/user_management/screens/user_list_screen.dart';
import 'features/management/task_type_management/screens/task_type_screen.dart';

// Importar o Modelo de Tarefa é necessário para a rota /task_details
import 'core/models/task_model.dart';

// O AuthStatus deveria vir do auth_provider.dart, mas é definido aqui para garantir
// que o AuthWrapper funciona, caso não tenha sido exportado.
enum AuthStatus { uninitialized, authenticated, unauthenticated }

// Ponto de entrada da aplicação
Future<void> main() async {
  // 1. Garantir que o Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar o Firebase (OBRIGATÓRIO)
  // Use 'currentPlatform' para garantir a compatibilidade entre iOS/Android/Web
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Instanciar os seus serviços (singletons)
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  final CsvService csvService = CsvService();

  // 4. Correr a aplicação com os Providers
  runApp(
    MultiProvider(
      providers: [
        // --- PROVIDERS CORE (Disponíveis em todo o lado) ---
        ChangeNotifierProvider(
          // AuthProvider depende dos serviços AuthService e FirestoreService
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Fornecer os serviços como Providers de tipo base para injeção de dependências
        Provider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => firestoreService),
        Provider<CsvService>(create: (_) => csvService),

        // --- PROVIDERS DAS FEATURES (Dependências que usam outros providers) ---
        ChangeNotifierProvider(
          // KanbanProvider depende do FirestoreService e do AuthProvider (para saber o utilizador logado)
          create: (context) =>
              KanbanProvider(firestoreService, context.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(firestoreService, authService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskTypeProvider(firestoreService),
        ),
        ChangeNotifierProvider(
          // ReportProvider depende do FirestoreService e do CsvService
          create: (_) => ReportProvider(firestoreService, csvService),
        ),
        ChangeNotifierProvider(
          // TaskDetailsProvider precisa apenas do serviço de dados
          create: (_) => TaskDetailsProvider(firestoreService),
        ),
      ],
      child: const ITasksApp(),
    ),
  );
}

// Widget Raiz da Aplicação
class ITasksApp extends StatelessWidget {
  const ITasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ouve o ThemeProvider para reagir a mudanças de tema (Claro/Escuro)
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'iTasks',
      debugShowCheckedModeBanner: false,

      // Aplicar os temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // AuthWrapper decide qual o primeiro ecrã a mostrar (Login ou Kanban)
      home: const AuthWrapper(),

      // Rotas nomeadas para navegação
      routes: {
        '/kanban': (context) => const KanbanScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/task_types': (context) => const TaskTypeScreen(),
        '/user_management': (context) => const UserListScreen(),

        // CORREÇÃO CRÍTICA: Rota que recebe argumentos (Task ou isReadOnly)
        '/task_details': (context) {
          final arguments =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final Task? task = arguments?['task'] as Task?;
          final bool isReadOnly = arguments?['isReadOnly'] ?? false;

          return TaskDetailsScreen(task: task, isReadOnly: isReadOnly);
        },
      },

      // Handler para rotas desconhecidas (opcional, mas bom para robustez)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Erro de Navegação')),
            body: Center(
              child: Text(
                'Rota não encontrada: ${settings.name}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Este widget "ouve" o AuthProvider e mostra o ecrã correto:
// Loading (Inicial) -> Login (Não Autenticado) -> Kanban (Autenticado)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const KanbanScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.uninitialized:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      default: // fallback to satisfy exhaustiveness
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
