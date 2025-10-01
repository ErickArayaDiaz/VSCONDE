import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import 'project_detail_screen.dart';
import 'add_project_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Proyectos")),
      body: projectProvider.projects.isEmpty
          ? const Center(child: Text("No hay proyectos aún."))
          : ListView.builder(
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];

                // Obtener tareas de este proyecto
                final tasks = taskProvider.tasks
                    .where(
                      (t) => t.projectId == project.id,
                    ) // project.id ahora es String
                    .toList();

                // Calcular progreso
                double progress = 0;
                if (tasks.isNotEmpty) {
                  final completed = tasks.where((t) => t.isDone).length;
                  progress = completed / tasks.length;
                }

                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción
                        Text(
                          project.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Fecha límite
                        Text(
                          "Fecha límite: ${project.deadline.day}/${project.deadline.month}/${project.deadline.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Barra de progreso
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 4),

                        // Porcentaje
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}% completado",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(project: project),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProjectScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
