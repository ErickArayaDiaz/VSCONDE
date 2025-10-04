// services/task_supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskSupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔼 Subir/actualizar tarea
  Future<void> uploadTask(Task task) async {
    await _client.from('tasks').upsert(task.toMap());
  }

  /// 🔽 Descargar todas las tareas
  Future<List<Task>> fetchTasks() async {
    final response = await _client.from('tasks').select();
    return (response as List)
        .map((t) => Task.fromMap(t as Map<String, dynamic>))
        .toList();
  }

  /// 🔽 Descargar tareas de un grupo específico
  Future<List<Task>> fetchGroupTasks(String groupId) async {
    final response =
        await _client.from('tasks').select().eq('group_id', groupId);
    return (response as List)
        .map((t) => Task.fromMap(t as Map<String, dynamic>))
        .toList();
  }

  /// ❌ Eliminar tarea
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}
