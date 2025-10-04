import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveService {
  static Future<Box<Task>> openTaskBox() async {
    return await Hive.openBox<Task>('tasks');
  }
}
