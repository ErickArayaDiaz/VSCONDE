import 'package:hive/hive.dart';

part 'task_history.g.dart';

@HiveType(typeId: 2)
class TaskHistory extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String status;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  int version;

  TaskHistory({
    required this.title,
    required this.description,
    required this.status,
    required this.updatedAt,
    required this.version,
  });
}
