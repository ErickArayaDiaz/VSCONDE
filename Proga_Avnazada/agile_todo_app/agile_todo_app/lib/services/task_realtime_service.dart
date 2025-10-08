// lib/services/task_realtime_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/task_history.dart';
import '../providers/task_provider.dart';

class TaskRealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _taskChannel;
  RealtimeChannel? _historyChannel;

  void subscribeToGroupTasks(String groupId, TaskProvider taskProvider) {
    _taskChannel?.unsubscribe();
    _taskChannel = _client.channel('public:tasks:$groupId');

    _taskChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'tasks',
        filter: 'group_id=eq.$groupId',
      ),
      (payload, [ref]) {
        try {
          final data = payload['new'] ?? payload['record'];
          if (data != null) {
            final task = Task.fromMap(Map<String, dynamic>.from(data as Map));
            // ✅ Solo mete en local, sin volver a sincronizar ni loguear
            taskProvider.addTaskFromRealtime(task);
          }
        } catch (e, st) {
          debugPrint('❌ Error en INSERT: $e\n$st');
        }
      },
    );

    _taskChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'UPDATE',
        schema: 'public',
        table: 'tasks',
        filter: 'group_id=eq.$groupId',
      ),
      (payload, [ref]) {
        try {
          final data = payload['new'] ?? payload['record'];
          if (data != null) {
            final task = Task.fromMap(Map<String, dynamic>.from(data as Map));
            // ✅ Solo mete en local, sin volver a sincronizar ni loguear
            taskProvider.addTaskFromRealtime(task);
          }
        } catch (e, st) {
          debugPrint('❌ Error en UPDATE: $e\n$st');
        }
      },
    );

    _taskChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'DELETE',
        schema: 'public',
        table: 'tasks',
        filter: 'group_id=eq.$groupId',
      ),
      (payload, [ref]) {
        try {
          final oldData = payload['old'] ?? payload['record'];
          if (oldData != null) {
            final id = (oldData as Map)['id'].toString();
            // ✅ Aquí podrías implementar una variante local (p.ej. delete local)
            // para no disparar sync; si no la tienes, deja como está.
            taskProvider.deleteTask(id);
          }
        } catch (e, st) {
          debugPrint('❌ Error en DELETE: $e\n$st');
        }
      },
    );

    _taskChannel!.subscribe();
  }

  void subscribeToHistory(String groupId, TaskProvider taskProvider) {
    _historyChannel?.unsubscribe();
    _historyChannel = _client.channel('public:task_history:$groupId');

    _historyChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*',
        schema: 'public',
        table: 'task_history',
        filter: 'group_id=eq.$groupId',
      ),
      (payload, [ref]) {
        try {
          final data = payload['new'] ?? payload['record'];
          if (data != null) {
            final history =
                TaskHistory.fromMap(Map<String, dynamic>.from(data as Map));
            taskProvider.addHistory(history);
          }
        } catch (e, st) {
          debugPrint('❌ Error en realtime history: $e\n$st');
        }
      },
    );

    _historyChannel!.subscribe();
  }

  void unsubscribe() {
    _taskChannel?.unsubscribe();
    _historyChannel?.unsubscribe();
    _taskChannel = null;
    _historyChannel = null;
  }
}
