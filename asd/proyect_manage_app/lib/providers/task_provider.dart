import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/database_helper.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks(int projectId) async {
    _tasks = await DatabaseHelper.instance.getTasks(projectId);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    await loadTasks(task.projectId);
  }

  Future<void> toggleTask(Task task) async {
    final updatedTask = Task(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      isDone: !task.isDone,
    );
    await DatabaseHelper.instance.updateTask(updatedTask);
    await loadTasks(task.projectId);
  }
}
