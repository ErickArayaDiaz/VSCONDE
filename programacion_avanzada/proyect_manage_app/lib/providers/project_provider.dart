import 'package:flutter/material.dart';
import '../models/project.dart';
import '../db/database_helper.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> loadProjects() async {
    _projects = await DatabaseHelper.instance.getProjects();
    notifyListeners(); // 🔔 actualiza la UI
  }

  Future<void> addProject(Project project) async {
    await DatabaseHelper.instance.insertProject(project);
    await loadProjects();
  }

  Future<void> deleteProject(int id) async {
    await DatabaseHelper.instance.deleteProject(id);
    await loadProjects();
  }
}
