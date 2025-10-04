// services/task_supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskSupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Subir o actualizar tarea en Supabase
  Future<void> uploadTask(Task task) async {
    await _client.from('tasks').upsert({
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
      'version': task.version,
      'group_id': task.groupId, // nuevo campo para grupos
    });
  }

  // Descargar tareas desde Supabase (filtradas por grupo)
  Future<List<Task>> fetchTasks(String groupId) async {
    final response =
        await _client.from('tasks').select().eq('group_id', groupId);

    if (response.isEmpty) return [];

    return response.map<Task>((row) => Task.fromMap(row)).toList();
  }

  Future<void> updateTask(Task task) async {
    await _client.from('tasks').update({
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'updated_at': task.updatedAt.toIso8601String(),
      'version': task.version,
      'group_id': task.groupId,
    }).eq('id', task.id);
  }

  Future<void> addTask(Task task) async {
    await _client.from('tasks').insert({
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
      'version': task.version,
      'group_id': task.groupId,
    });
  }
}
