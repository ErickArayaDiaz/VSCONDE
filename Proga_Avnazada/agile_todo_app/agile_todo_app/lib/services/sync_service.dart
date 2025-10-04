// services/sync_service.dart
import '../models/task.dart';
import 'hive_service.dart';
import 'task_supabase_service.dart';

class SyncService {
  final TaskSupabaseService _supabaseService = TaskSupabaseService();

  /// Sincroniza las tareas de un grupo entre Hive y Supabase
  Future<void> syncTasks(String groupId) async {
    final taskBox = await HiveService.openTaskBox();

    // 🔼 Subir tareas locales al servidor
    for (var task in taskBox.values) {
      if (task.groupId != groupId)
        continue; // solo sincroniza las del grupo actual

      try {
        // si la tarea ya existe en Supabase → update, sino → insert
        await _supabaseService.updateTask(task);
      } catch (e) {
        await _supabaseService.addTask(task);
      }
    }

    // 🔽 Descargar tareas desde Supabase
    final cloudTasks = await _supabaseService.fetchTasks(groupId);
    for (var t in cloudTasks) {
      if (!taskBox.containsKey(t.id)) {
        await taskBox.put(t.id, t);
      } else {
        final local = taskBox.get(t.id);
        if (local != null && t.version > local.version) {
          await taskBox.put(t.id, t);
        }
      }
    }
  }
}
