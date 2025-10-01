class Project {
  final String? id; // uuid en Supabase
  final String name;
  final String description;
  final DateTime deadline;
  final DateTime updatedAt;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.deadline,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
