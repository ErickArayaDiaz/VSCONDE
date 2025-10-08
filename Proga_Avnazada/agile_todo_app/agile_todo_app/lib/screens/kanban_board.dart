//  screens/kanban_board.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

import 'package:uuid/uuid.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final _uuid = const Uuid();

    return Scaffold(
      appBar: AppBar(title: const Text("Kanban Board")),
      body: Row(
        children: [
          _buildTaskColumn(
              context,
              "To Do",
              provider.tasks.where((t) => t.status == "todo").toList(),
              provider),
          _buildTaskColumn(
              context,
              "In Progress",
              provider.tasks.where((t) => t.status == "in_progress").toList(),
              provider),
          _buildTaskColumn(
              context,
              "Done",
              provider.tasks.where((t) => t.status == "done").toList(),
              provider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ Crear tarea con todos los campos requeridos
          final task = Task(
            id: _uuid.v4(), // ✅ UUID v4
            title: "Nueva tarea",
            description: "Descripción pendiente", // 🔹 requerido
            status: "todo",
            groupId: provider.currentGroupId ?? "default", // 🔹 ahora agregado
          );
          provider.addTask(task);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskColumn(BuildContext context, String status, List<Task> tasks,
      TaskProvider provider) {
    return Expanded(
      child: DragTarget<Task>(
        onAccept: (task) {
          provider.updateTaskStatus(task, status);
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text(status,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: tasks
                        .map((task) => Draggable<Task>(
                              data: task,
                              feedback: Material(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.blue,
                                  child: Text(task.title,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.5,
                                child: ListTile(
                                  title: Text(task.title),
                                  subtitle: Text(task.description),
                                ),
                              ),
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Text(task.description),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
