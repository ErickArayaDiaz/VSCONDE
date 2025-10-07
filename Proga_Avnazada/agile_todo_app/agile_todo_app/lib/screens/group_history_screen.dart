// lib/screens/group_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_history.dart';

class GroupHistoryScreen extends StatelessWidget {
  const GroupHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    final histories = provider.histories
        .where((h) => h.groupId == provider.currentGroupId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(title: const Text("Historial del Grupo")),
      body: ListView.builder(
        itemCount: histories.length,
        itemBuilder: (_, index) {
          final TaskHistory h = histories[index];
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text("${h.userName ?? h.userId} ${h.action} una tarea"),
            subtitle: Text(
                "Tarea ID: ${h.taskId} • ${h.timestamp.toLocal().toString()}"),
          );
        },
      ),
    );
  }
}
