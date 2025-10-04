import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class LocalUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String email;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime createdAt;

  LocalUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory LocalUser.fromMap(Map<String, dynamic> m) {
    return LocalUser(
      id: m['id'] as String,
      email: m['email'] as String? ?? '',
      name: m['name'] as String? ?? '',
      createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
