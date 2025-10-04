import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskSupabaseService {
  final _supabase = Supabase.instance.client;

  // 🔼 Subir o actualizar tarea
  Future<void> uploadTask(Task task) async {
    await _supabase.from('tasks').upsert({
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'created_at': task.createdAt.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
      'version': task.version,
    });
  }

  // 🔽 Descargar tareas
  Future<List<Task>> fetchTasks() async {
    final response = await _supabase.from('tasks').select();
    return (response as List).map((json) {
      return Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        version: json['version'],
      );
    }).toList();
  }

  // ❌ Eliminar tarea
  Future<void> deleteTask(String id) async {
    await _supabase.from('tasks').delete().eq('id', id);
  }
}
