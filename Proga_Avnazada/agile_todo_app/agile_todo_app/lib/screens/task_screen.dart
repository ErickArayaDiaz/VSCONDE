// lib/screens/task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_history_screen.dart';
import 'package:uuid/uuid.dart';

import 'join_group_screen.dart'; // ✅ nuevo import

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tablero Kanban')),
      body: Row(
        children: [
          Expanded(child: _buildColumn(context, taskProvider, "todo", "To Do")),
          Expanded(
              child: _buildColumn(
                  context, taskProvider, "in_progress", "In Progress")),
          Expanded(child: _buildColumn(context, taskProvider, "done", "Done")),
          Expanded(
              child: _buildColumn(context, taskProvider, "finished", "Done")),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "add_task",
            child: const Icon(Icons.add),
            onPressed: () {
              if (taskProvider.currentGroupId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecciona un grupo antes de crear tareas'),
                  ),
                );
                return;
              }
              _showAddTaskDialog(context, taskProvider);
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "join_group",
            child: const Icon(Icons.group_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, TaskProvider provider,
      String status, String title) {
    final tasks = provider.getTasksByStatus(status);
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    onTap: () => _showEditTaskDialog(context, provider, task),
                    trailing: IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskHistoryScreen(taskId: task.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider provider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final _uuid = const Uuid();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final task = Task(
                id: _uuid.v4(),
                title: titleCtrl.text,
                description: descCtrl.text,
              );
              provider.addTask(task);
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(
      BuildContext context, TaskProvider provider, Task task) {
    final titleCtrl = TextEditingController(text: task.title);
    final descCtrl = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Título')),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción')),
            // ✅ Dropdown sin setState
            Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                return DropdownButton<String>(
                  value: task.status,
                  onChanged: (newValue) async {
                    if (newValue != null) {
                      await taskProvider.updateTaskStatus(task, newValue);
                    }
                  },
                  items: ['todo', 'in_progress', 'done']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              task.update(
                newTitle: titleCtrl.text,
                newDesc: descCtrl.text,
                newStatus: task.status,
              );
              provider.updateTask(task);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
