// 📦 services/sync_service.dart
import '../models/task.dart';
import 'hive_service.dart';
import 'task_supabase_service.dart';

class SyncService {
  final TaskSupabaseService _supabaseService = TaskSupabaseService();

  Future<void> syncTasks() async {
    final taskBox = await HiveService.openTaskBox();

    // 🔼 Subir tareas locales a Supabase
    for (var task in taskBox.values) {
      try {
        await _supabaseService.uploadTask(task);
      } catch (e) {
        print('❌ Error uploading task ${task.id}: $e');
      }
    }

    // 🔽 Descargar tareas desde Supabase
    try {
      final cloudTasks = await _supabaseService.fetchTasks();

      for (var t in cloudTasks) {
        if (!taskBox.containsKey(t.id)) {
          // Nueva tarea del servidor → agregar localmente
          await taskBox.put(t.id, t);
        } else {
          final local = taskBox.get(t.id);
          // Actualizar si la versión en la nube es más reciente
          if (local != null && t.version > local.version) {
            await taskBox.put(t.id, t);
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching tasks from Supabase: $e');
    }
  }
}
