// lib/services/sync_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/task_history.dart';
import 'hive_service.dart';
import 'task_supabase_service.dart';
import 'connection_service.dart';

class SyncService {
  final TaskSupabaseService _supabaseService = TaskSupabaseService();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> syncTasks() async {
    if (!await ConnectionService.hasConnection()) {
      print("⚠️ No hay conexión a Internet, se omite syncTasks()");
      return;
    }
    final taskBox = await HiveService.openTaskBox();
    for (var task in taskBox.values) {
      // ⛔ Evita violar RLS: si no hay grupo, no subas
      if (task.groupId == null) {
        print("↪️ skip upload task ${task.id} (sin group_id)");
        continue;
      }
      try {
        await _supabaseService.uploadTask(task);
      } catch (e) {
        print('❌ Error subiendo tarea ${task.id}: $e');
      }
    }
    try {
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
    } catch (e) {
      print('❌ Error descargando tareas: $e');
    }
  }

  Future<void> syncTaskHistory() async {
    if (!await ConnectionService.hasConnection()) {
      print("⚠️ No hay conexión a Internet, se omite syncTaskHistory()");
      return;
    }
    final historyBox = await HiveService.openHistoryBox();
    final allHistories = historyBox.values.toList();

    for (var history in allHistories) {
      // ⛔ Evita violar RLS: si no hay grupo, no subas
      if (history.groupId == null) {
        print("↪️ skip upload history ${history.id} (sin group_id)");
        continue;
      }
      try {
        await supabase.from('task_history').upsert(history.toMap());
      } catch (e) {
        print('⚠️ Error subiendo historial: $e');
      }
    }

    try {
      final response = await supabase.from('task_history').select();
      for (var h in response) {
        final history = TaskHistory.fromMap(Map<String, dynamic>.from(h));
        if (!historyBox.containsKey(history.id)) {
          await historyBox.put(history.id, history);
        }
      }
    } catch (e) {
      print('❌ Error descargando historiales: $e');
    }
  }
}
