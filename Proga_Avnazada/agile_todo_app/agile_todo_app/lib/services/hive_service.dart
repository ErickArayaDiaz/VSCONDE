// services/hive_service.dart
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../models/task_history.dart';

class HiveService {
  static Future<Box<Task>> openTaskBox() async {
    return await Hive.openBox<Task>('tasks');
  }

  static Future<Box<TaskHistory>> openHistoryBox() async {
    return await Hive.openBox<TaskHistory>('task_history');
  }
}
