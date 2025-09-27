import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('project_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      deadline TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      projectId INTEGER NOT NULL,
      title TEXT NOT NULL,
      isDone INTEGER NOT NULL,
      FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
    )
    ''');
  }

  // 🔹 Métodos para proyectos
  Future<int> insertProject(Project project) async {
    final db = await instance.database;
    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getProjects() async {
    final db = await instance.database;
    final result = await db.query('projects');
    return result.map((e) => Project.fromMap(e)).toList();
  }

  // 🔹 Métodos para tareas
  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks(int projectId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
    return result.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await instance.database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}
