// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../services/hive_service.dart';
import '../services/sync_service.dart';

class TaskProvider extends ChangeNotifier {
  Box<Task>? _taskBox;
  List<Task> tasks = [];

  final SyncService _syncService = SyncService();

  String? currentGroupId; // grupo actual seleccionado

  TaskProvider() {
    _init();
  }

  // Inicializa Hive y sincroniza con Supabase
  Future<void> _init() async {
    _taskBox = await HiveService.openTaskBox();
    tasks = _taskBox!.values.toList();

    // sincroniza con Supabase (sin argumentos)
    await _syncService.syncTasks();
    tasks = _taskBox!.values.toList();

    notifyListeners();
  }

  // Cambiar grupo activo
  void setGroup(String groupId) {
    currentGroupId = groupId;
    _loadGroupTasks();
  }

  // Cargar solo las tareas del grupo actual
  Future<void> _loadGroupTasks() async {
    if (currentGroupId == null) {
      tasks = _taskBox!.values.toList(); // si no hay grupo, muestra todas
    } else {
      final allTasks = _taskBox!.values.toList();
      tasks = allTasks.where((t) => t.groupId == currentGroupId).toList();
    }
    notifyListeners();
  }

  // Agregar tarea al grupo actual
  Future<void> addTask(Task task) async {
    if (currentGroupId != null) {
      task.groupId = currentGroupId!; // asignar grupo actual
    }
    await _taskBox!.put(task.id, task);

    await _syncService.syncTasks(); // sin argumentos
    await _loadGroupTasks();
  }

  // Actualizar tarea
  Future<void> updateTask(Task task) async {
    await _taskBox!.put(task.id, task);

    await _syncService.syncTasks(); // sin argumentos
    await _loadGroupTasks();
  }

  // Eliminar tarea
  Future<void> deleteTask(String taskId) async {
    await _taskBox!.delete(taskId);

    await _syncService.syncTasks(); // sin argumentos
    await _loadGroupTasks();
  }

  // Obtener tareas por estado (ej: "todo", "doing", "done")
  List<Task> getTasksByStatus(String status) {
    return tasks.where((t) => t.status == status).toList();
  }

  // Actualizar estado de tarea (para drag & drop)
  void updateTaskStatus(Task task, String newStatus) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        status: newStatus,
        groupId: task.groupId,
      );
      notifyListeners();
    }
  }
}
