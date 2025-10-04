import '../models/task.dart';
import 'hive_service.dart';
import 'task_supabase_service.dart';

class SyncService {
  final TaskSupabaseService _supabaseService = TaskSupabaseService();

  Future<void> syncTasks() async {
    final taskBox = await HiveService.openTaskBox();

    // 🔼 Subir tareas locales
    for (var task in taskBox.values) {
      await _supabaseService.uploadTask(task);
    }

    // 🔽 Descargar tareas
    final cloudTasks = await _supabaseService.fetchTasks();
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
