class Task {
  final int? id;
  final int projectId; // Relación: a qué proyecto pertenece
  final String title;
  final bool isDone; // true = completada

  Task({
    this.id,
    required this.projectId,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'isDone': isDone ? 1 : 0, // SQLite no maneja bool, usamos 0/1
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }
}
