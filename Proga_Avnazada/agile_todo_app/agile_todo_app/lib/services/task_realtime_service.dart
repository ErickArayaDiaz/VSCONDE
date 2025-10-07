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

  /// 📡 Suscripción a cambios en `tasks`
  void subscribeToGroupTasks(String groupId, TaskProvider taskProvider) {
    _taskChannel?.unsubscribe();
    _taskChannel = _client.channel('public:tasks:$groupId');

    // INSERT
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
            taskProvider.addTask(task);
          }
        } catch (e, st) {
          debugPrint('❌ Error procesando INSERT: $e\n$st');
        }
      },
    );

    // UPDATE
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
            taskProvider.updateTask(task);
          }
        } catch (e, st) {
          debugPrint('❌ Error procesando UPDATE: $e\n$st');
        }
      },
    );

    // DELETE
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
            taskProvider.deleteTask(id);
          }
        } catch (e, st) {
          debugPrint('❌ Error procesando DELETE: $e\n$st');
        }
      },
    );

    _taskChannel!.subscribe();
  }

  /// 📡 Suscripción a cambios en `task_history`
  void subscribeToHistory(String groupId, TaskProvider taskProvider) {
    _historyChannel?.unsubscribe();
    _historyChannel = _client.channel('public:task_history:$groupId');

    _historyChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: '*', // INSERT / UPDATE / DELETE
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
          debugPrint('❌ Error procesando realtime history: $e\n$st');
        }
      },
    );

    _historyChannel!.subscribe();
  }

  /// ❌ Cierra las suscripciones
  void unsubscribe() {
    _taskChannel?.unsubscribe();
    _historyChannel?.unsubscribe();
    _taskChannel = null;
    _historyChannel = null;
  }
}
