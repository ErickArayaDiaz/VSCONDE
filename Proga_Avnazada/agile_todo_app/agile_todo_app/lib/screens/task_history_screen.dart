// lib/screens/task_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_history.dart';

class TaskHistoryScreen extends StatelessWidget {
  final String taskId;
  const TaskHistoryScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Filtrar solo el historial de esta tarea
    final histories = taskProvider.histories
        .where((h) => h.taskId == taskId)
        .toList()
      ..sort(
          (a, b) => b.timestamp.compareTo(a.timestamp)); // más recientes arriba

    return Scaffold(
      appBar: AppBar(title: const Text("Historial de cambios")),
      body: histories.isEmpty
          ? const Center(child: Text("No hay historial disponible"))
          : ListView.builder(
              itemCount: histories.length,
              itemBuilder: (_, i) {
                final h = histories[i];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text("${h.action} por ${h.userId}"),
                  subtitle: Text("en ${h.timestamp.toLocal()}"),
                );
              },
            ),
    );
  }
}
