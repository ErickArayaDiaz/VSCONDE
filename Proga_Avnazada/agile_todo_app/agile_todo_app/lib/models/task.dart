import 'package:hive/hive.dart';
import 'task_history.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String status; // "todo", "in_progress", "done"

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  int version; // contador de versiones

  @HiveField(7)
  List<TaskHistory> history; // historial de cambios

  @HiveField(8)
  String? groupId; // grupo al que pertenece la tarea

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.status = "todo",
    DateTime? createdAt,
    DateTime? updatedAt,
    this.version = 1,
    List<TaskHistory>? history,
    this.groupId,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        history = history ?? [];

  void update({String? newTitle, String? newDesc, String? newStatus}) {
    // Guardar en historial antes de actualizar
    history.add(TaskHistory(
      title: title,
      description: description,
      status: status,
      updatedAt: updatedAt,
      version: version,
    ));
    version += 1;
    if (newTitle != null) title = newTitle;
    if (newDesc != null) description = newDesc;
    if (newStatus != null) status = newStatus;
    updatedAt = DateTime.now();
  }

  /// 🔄 Conversión desde Supabase/Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] ?? '',
      status: map['status'] ?? 'todo',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      version: map['version'] ?? 1,
      groupId: map['group_id'],
      history: [], // Supabase no almacena historial, solo local
    );
  }

  /// 🔄 Conversión a Map (para Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'version': version,
      'group_id': groupId,
    };
  }
}
