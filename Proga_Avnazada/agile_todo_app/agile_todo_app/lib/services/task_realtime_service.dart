import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskRealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  /// Suscribir a cambios en la tabla `tasks` de un grupo
  void subscribeToGroupTasks(String groupId, TaskProvider taskProvider) {
    // Cierra suscripciones previas
    _channel?.unsubscribe();

    _channel = _client.channel('public:tasks')
      ..on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'tasks',
          filter: 'group_id=eq.$groupId',
        ),
        (payload, [ref]) {
          debugPrint('Nueva tarea añadida: ${payload['new']}');
          final task = Task.fromMap(payload['new'] as Map<String, dynamic>);
          taskProvider.addTask(task);
        },
      )
      ..on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'UPDATE',
          schema: 'public',
          table: 'tasks',
          filter: 'group_id=eq.$groupId',
        ),
        (payload, [ref]) {
          debugPrint('Tarea actualizada: ${payload['new']}');
          final task = Task.fromMap(payload['new'] as Map<String, dynamic>);
          taskProvider.updateTask(task);
        },
      )
      ..on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'DELETE',
          schema: 'public',
          table: 'tasks',
          filter: 'group_id=eq.$groupId',
        ),
        (payload, [ref]) {
          debugPrint('Tarea eliminada: ${payload['old']}');
          final taskId =
              (payload['old'] as Map<String, dynamic>)['id'].toString();
          taskProvider.deleteTask(taskId);
        },
      )
      ..subscribe();
  }

  /// Cierra la suscripción
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
