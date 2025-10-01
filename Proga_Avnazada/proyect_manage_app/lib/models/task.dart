class Task {
  final String? id;
  final String projectId;
  final String title;
  final bool isDone;
  final DateTime updatedAt;

  Task({
    this.id,
    required this.projectId,
    required this.title,
    this.isDone = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'isDone': isDone,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toString(),
      projectId: map['projectId'] ?? '',
      title: map['title'] ?? '',
      isDone: map['isDone'] == true || map['isDone'] == 1,
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
