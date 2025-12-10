import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/services/csv_service.dart';

import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

import 'features/kanban/providers/kanban_provider.dart';
import 'features/kanban/providers/task_details_provider.dart';
import 'features/management/user_management/providers/user_management_provider.dart';
import 'features/management/task_type_management/providers/task_type_provider.dart';
import 'features/reports/providers/report_provider.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/kanban/screens/kanban_screen.dart';
import 'features/kanban/screens/task_details_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/management/user_management/screens/user_list_screen.dart';
import 'features/management/task_type_management/screens/task_type_screen.dart';
import 'core/models/task_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  final CsvService csvService = CsvService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, firestoreService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        Provider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => firestoreService),
        Provider<CsvService>(create: (_) => csvService),

        ChangeNotifierProvider(
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
          create: (_) => ReportProvider(firestoreService, csvService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskDetailsProvider(firestoreService),
        ),
      ],
      child: const ITasksApp(),
    ),
  );
}

class ITasksApp extends StatelessWidget {
  const ITasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'iTasks',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      home: const AuthWrapper(),

      routes: {
        '/kanban': (context) => const KanbanScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/task_types': (context) => const TaskTypeScreen(),
        '/user_management': (context) => const UserListScreen(),
        '/task_details': (context) {
          final arguments =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final Task? task = arguments?['task'] as Task?;
          final bool isReadOnly = arguments?['isReadOnly'] ?? false;

          return TaskDetailsScreen(task: task, isReadOnly: isReadOnly);
        },
      },

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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    print('🔍 AuthWrapper: STATUS = ${authProvider.status}');

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        print('🔍 AuthWrapper: Mostrando KanbanScreen');
        return const KanbanScreen();
      case AuthStatus.unauthenticated:
        print('🔍 AuthWrapper: Mostrando LoginScreen');
        return const LoginScreen();
      case AuthStatus.uninitialized:
        print('🔍 AuthWrapper: Mostrando CircularProgressIndicator');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      default: // fallback to satisfy exhaustiveness
        print('🔍 AuthWrapper: DEFAULT - Mostrando CircularProgressIndicator');
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
