import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  /// Cargar tareas de un proyecto específico
  Future<void> fetchTasks(String projectId) async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('project_id', projectId);

    _tasks = (response as List).map((t) => Task.fromMap(t)).toList();
    notifyListeners();
  }

  /// Agregar una nueva tarea
  Future<void> addTask(Task task) async {
    await supabase.from('tasks').insert(task.toMap());
    await fetchTasks(task.projectId);
  }

  /// Actualizar estado de tarea (completada o no)
  Future<void> toggleTask(Task task) async {
    await supabase
        .from('tasks')
        .update({'is_done': !task.isDone})
        .eq('id', task.id!);

    await fetchTasks(task.projectId);
  }

  /// Eliminar tarea
  Future<void> deleteTask(String id, String projectId) async {
    await supabase.from('tasks').delete().eq('id', id);
    await fetchTasks(projectId);
  }

  /// Suscribirse a cambios en tiempo real
  void subscribeToChanges(String projectId) {
    supabase.channel('public:tasks').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'tasks'),
      (payload, [ref]) async {
        await fetchTasks(projectId);
      },
    ).subscribe();
  }
}
