// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/constants.dart';
import 'models/user.dart';
import 'models/task.dart';
import 'models/task_history.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LocalUserAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskHistoryAdapter());

  // Abrimos TODAS las cajas antes de levantar la app
  final localUserBox = await Hive.openBox<LocalUser>('local_user');
  final taskBox = await Hive.openBox<Task>('tasks');
  final historyBox = await Hive.openBox<TaskHistory>('task_history');

  runApp(MyApp(
    taskBox: taskBox,
    historyBox: historyBox,
  ));
}

class MyApp extends StatelessWidget {
  final Box<Task> taskBox;
  final Box<TaskHistory> historyBox;

  const MyApp({
    super.key,
    required this.taskBox,
    required this.historyBox,
  });

  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 👉 TaskProvider recibe las cajas YA ABIERTAS (sin _init async)
        provider.ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskBox: taskBox,
            historyBox: historyBox,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Agile ToDo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const Root(),
      ),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = provider.Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.localUser != null) {
      // Opcional: pasar userId/userName al TaskProvider
      final tp = provider.Provider.of<TaskProvider>(context, listen: false);
      tp.setUser(auth.localUser!.id, auth.localUser!.name);
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
