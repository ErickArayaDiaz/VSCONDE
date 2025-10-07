// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/task_history.dart';
import '../services/hive_service.dart';
import '../services/sync_service.dart';
import '../services/task_realtime_service.dart';

class TaskProvider extends ChangeNotifier {
  Box<Task>? _taskBox;
  Box<TaskHistory>? _historyBox;
  List<Task> tasks = [];
  List<TaskHistory> histories = [];

  final SyncService _syncService = SyncService();
  final TaskRealtimeService _realtimeService = TaskRealtimeService();
  final _uuid = Uuid();

  String? currentGroupId;
  String? currentUserId;

  TaskProvider({this.currentUserId}) {
    _init();
  }

  Future<void> _init() async {
    _taskBox = await HiveService.openTaskBox();
    _historyBox = await HiveService.openHistoryBox();

    tasks = _taskBox!.values.toList();
    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    notifyListeners();
  }

  void setGroup(String groupId) {
    // Guardamos el grupo activo
    currentGroupId = groupId;

    // Cargamos tareas locales filtradas por el grupo
    _loadGroupTasks();

    // 🔌 Primero cancelamos suscripciones previas
    _realtimeService.unsubscribe();

    // 📡 Ahora activamos las dos suscripciones (tasks + history)
    _realtimeService.subscribeToGroupTasks(groupId, this);
    _realtimeService.subscribeToHistory(groupId, this);

    debugPrint("✅ Grupo cambiado a $groupId con suscripciones activas.");
  }

  Future<void> _loadGroupTasks() async {
    if (currentGroupId == null) {
      tasks = _taskBox!.values.toList();
    } else {
      final allTasks = _taskBox!.values.toList();
      tasks = allTasks.where((t) => t.groupId == currentGroupId).toList();
    }
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    if (currentGroupId != null) task.groupId = currentGroupId!;
    await _taskBox!.put(task.id, task);

    await _logHistory(task.id, 'created');
    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    await _loadGroupTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskBox!.put(task.id, task);
    await _logHistory(task.id, 'updated');

    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    await _loadGroupTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox!.delete(taskId);
    await _logHistory(taskId, 'deleted');

    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    await _loadGroupTasks();
  }

  void updateTaskStatus(Task task, String newStatus) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index].status = newStatus;
      _taskBox!.put(task.id, tasks[index]);
      _logHistory(task.id, 'moved');
      notifyListeners();
    }
  }

  Future<void> _logHistory(String taskId, String action) async {
    final history = TaskHistory(
      id: _uuid.v4(),
      taskId: taskId,
      userId: currentUserId ?? 'unknown',
      action: action,
      groupId: currentGroupId, // ✅ ahora guardamos grupo
    );
    await _historyBox!.put(history.id, history);
  }

  List<Task> getTasksByStatus(String status) {
    return tasks.where((t) => t.status == status).toList();
  }

  void addHistory(TaskHistory history) {
    histories.add(history);
    notifyListeners();
  }

  Future<void> logHistory(TaskHistory history) async {
    await _historyBox!.put(history.id, history);
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe(); // ✅ corta la conexión al destruir provider
    super.dispose();
  }
}
