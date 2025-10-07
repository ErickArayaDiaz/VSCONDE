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

  /// 🔄 Sincroniza tareas con Supabase solo si hay Internet
  Future<void> syncTasks() async {
    if (!await ConnectionService.hasConnection()) {
      print("⚠️ No hay conexión a Internet, se omite syncTasks()");
      return;
    }

    final taskBox = await HiveService.openTaskBox();

    // 🔼 Subir tareas locales
    for (var task in taskBox.values) {
      try {
        await _supabaseService.uploadTask(task);
      } catch (e) {
        print('❌ Error subiendo tarea ${task.id}: $e');
      }
    }

    // 🔽 Descargar tareas
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

  /// 🔄 Sincroniza los historiales con Supabase
  Future<void> syncTaskHistory() async {
    if (!await ConnectionService.hasConnection()) {
      print("⚠️ No hay conexión a Internet, se omite syncTaskHistory()");
      return;
    }

    final historyBox = await HiveService.openHistoryBox();
    final allHistories = historyBox.values.toList();

    for (var history in allHistories) {
      try {
        await supabase.from('task_history').upsert(history.toMap());
      } catch (e) {
        print('⚠️ Error subiendo historial: $e');
      }
    }
  }
}
