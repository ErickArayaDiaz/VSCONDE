// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://mjasxxpnshypxacnzqqr.supabase.co', // <- pon tu URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qYXN4eHBuc2h5cHhhY256cXFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwODc3NDcsImV4cCI6MjA3NDY2Mzc0N30.Y0qW2DSts5e0LAeUnnrGvUZQOhqydVRw_T7AVEmSyNk', // <- pon tu anon key
  );

  // Inicializar Hive
  await Hive.initFlutter();

  // Inicializar Timezone
  tz.initializeTimeZones();
  final String localName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(localName));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()..init()),
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
