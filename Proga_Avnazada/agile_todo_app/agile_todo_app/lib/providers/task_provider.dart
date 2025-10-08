// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';
import '../models/task_history.dart';
import '../services/sync_service.dart';
import '../services/task_realtime_service.dart';

class TaskProvider extends ChangeNotifier {
  // ✅ Cajas ya abiertas (inyectadas desde main.dart)
  final Box<Task> _taskBox;
  final Box<TaskHistory> _historyBox;

  // Estado en memoria
  List<Task> tasks = [];
  List<TaskHistory> histories = [];

  // Servicios
  final SyncService _syncService = SyncService();
  final TaskRealtimeService _realtimeService = TaskRealtimeService();
  final _uuid = const Uuid();

  // Contexto actual
  String? currentGroupId;
  String? currentUserId;
  String? currentUserName;

  TaskProvider({
    required Box<Task> taskBox,
    required Box<TaskHistory> historyBox,
    this.currentUserId,
  })  : _taskBox = taskBox,
        _historyBox = historyBox {
    // 🔹 Al crear el provider, ya tenemos las cajas abiertas
    tasks = _taskBox.values.toList();
    // (opcional) podrías disparar un primer sync aquí si quieres:
    // _primeSync();
  }

  Future<void> _primeSync() async {
    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    _reloadByGroup();
  }

  // Para setear el usuario actual (lo hacemos desde Root al loguear)
  void setUser(String userId, String userName) {
    currentUserId = userId;
    currentUserName = userName;
  }

  // Cambio de grupo: recarga y activa realtime
  void setGroup(String groupId) {
    currentGroupId = groupId;
    _reloadByGroup();

    _realtimeService.unsubscribe();
    _realtimeService.subscribeToGroupTasks(groupId, this);
    _realtimeService.subscribeToHistory(groupId, this);
  }

  // Carga tareas según grupo seleccionado
  void _reloadByGroup() {
    if (currentGroupId == null) {
      tasks = _taskBox.values.toList();
    } else {
      tasks =
          _taskBox.values.where((t) => t.groupId == currentGroupId).toList();
    }
    notifyListeners();
  }

  // ---------- CRUD TAREAS (local + sync) ----------

  Future<void> addTask(Task task) async {
    if (currentGroupId != null) task.groupId = currentGroupId!;
    await _taskBox.put(task.id, task);

    await _logHistory(task.id, 'created');
    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    _reloadByGroup();
  }

  // 🔹 Para eventos realtime: NO re-sincroniza ni re-loguea
  void addTaskFromRealtime(Task task) {
    _taskBox.put(task.id, task);
    // si hay grupo seleccionado, filtramos
    if (currentGroupId == null || task.groupId == currentGroupId) {
      final idx = tasks.indexWhere((t) => t.id == task.id);
      if (idx == -1) tasks.add(task);
    }
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
    await _logHistory(task.id, 'updated');

    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    _reloadByGroup();
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
    await _logHistory(taskId, 'deleted');

    await _syncService.syncTasks();
    await _syncService.syncTaskHistory();
    _reloadByGroup();
  }

  void updateTaskStatus(Task task, String newStatus) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index].status = newStatus;
      _taskBox.put(task.id, tasks[index]);
      _logHistory(task.id, 'moved');
      notifyListeners();
    }
  }

  // ---------- HISTORIAL ----------

  Future<void> _logHistory(String taskId, String action) async {
    final history = TaskHistory(
      id: _uuid.v4(),
      taskId: taskId,
      userId: currentUserId ?? 'unknown',
      action: action,
      groupId: currentGroupId,
      userName: currentUserName ?? 'Unknown',
    );
    await _historyBox.put(history.id, history);
  }

  List<Task> getTasksByStatus(String status) =>
      tasks.where((t) => t.status == status).toList();

  void addHistory(TaskHistory history) {
    histories.add(history);
    notifyListeners();
  }

  Future<void> logHistory(TaskHistory history) async {
    await _historyBox.put(history.id, history);
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeService.unsubscribe();
    super.dispose();
  }
}
