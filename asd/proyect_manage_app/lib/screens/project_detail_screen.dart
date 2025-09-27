import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas del proyecto al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(
        context,
        listen: false,
      ).loadTasks(widget.project.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      body: taskProvider.tasks.isEmpty
          ? const Center(child: Text("No hay tareas aún."))
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return CheckboxListTile(
                  title: Text(task.title),
                  value: task.isDone,
                  onChanged: (_) {
                    taskProvider.toggleTask(task);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, taskProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskProvider taskProvider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nueva tarea"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Título de la tarea"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newTask = Task(
                  projectId: widget.project.id!,
                  title: controller.text,
                );
                taskProvider.addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
