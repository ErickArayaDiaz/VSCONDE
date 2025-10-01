import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://mjasxxpnshypxacnzqqr.supabase.co', // pon tu URL aquí
    anonKey: 'sb_publishable_86HA7CimXy3vsX7-zgeFEQ_TgHTPGY6', // tu Anon Key
  );

  // Inicializar Hive (para modo offline/local)
  await Hive.initFlutter();

  // Inicializar Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.local);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Proyectos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
