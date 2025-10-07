// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/constants.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart'; // 👈 Importar TaskProvider
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LocalUserAdapter());
  await Hive.openBox<LocalUser>('local_user');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
        provider.ChangeNotifierProvider(
            create: (_) => TaskProvider()), // ✅ agregado
      ],
      child: MaterialApp(
        title: 'Agile ToDo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
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

    // Mientras carga estado
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si hay usuario logueado → Home
    if (auth.localUser != null) {
      return const HomeScreen();
    }

    // Si no → Login
    return const LoginScreen();
  }
}
