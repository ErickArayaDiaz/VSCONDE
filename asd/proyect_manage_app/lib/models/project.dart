class Project {
  final int? id; // id autoincremental en SQLite
  final String name; // nombre del proyecto
  final String description; // descripción
  final DateTime deadline; // fecha límite

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.deadline,
  });

  // Convertir Project a un Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deadline': deadline.toIso8601String(),
    };
  }

  // Convertir Map de SQLite a objeto Project
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
