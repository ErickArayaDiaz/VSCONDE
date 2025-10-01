import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.fetchTasks(widget.project.id!); // cargar tareas al abrir
    taskProvider.subscribeToChanges(widget.project.id!); // escuchar realtime
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.project.description,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Fecha límite
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Fecha límite: ${widget.project.deadline.day}/${widget.project.deadline.month}/${widget.project.deadline.year}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),

          const Divider(),

          // Lista de tareas
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("No hay tareas aún."))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) {
                            taskProvider.toggleTask(task);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            taskProvider.deleteTask(task.id!, task.projectId);
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Input para agregar tarea
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: "Nueva tarea...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      final newTask = Task(
                        projectId: widget.project.id!,
                        title: _taskController.text,
                      );
                      taskProvider.addTask(newTask);
                      _taskController.clear();
                    }
                  },
                  child: const Text("Añadir"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
