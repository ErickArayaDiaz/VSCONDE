// lib/models/task_history.dart
import 'package:hive/hive.dart';

part 'task_history.g.dart';

@HiveType(typeId: 2)
class TaskHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String taskId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String action;

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? groupId;

  @HiveField(6)
  String? userName;

  TaskHistory({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.action,
    DateTime? timestamp,
    this.groupId,
    this.userName,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TaskHistory.fromMap(Map<String, dynamic> map) {
    return TaskHistory(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      userId: map['user_id'] as String,
      action: map['action'] as String,
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      groupId: map['group_id'],
      userName: map['user_name'], // opcional si lo agregas en Supabase
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'group_id': groupId,
      'user_name': userName,
    };
  }
}
