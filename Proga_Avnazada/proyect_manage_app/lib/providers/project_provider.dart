import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class ProjectProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<Project> _projects = [];
  late Box<Project> _projectBox;

  List<Project> get projects => _projects;

  Future<void> init() async {
    _projectBox = await Hive.openBox<Project>('projects');
    _projects = _projectBox.values.toList();
    notifyListeners();

    await syncWithSupabase();
  }

  Future<void> addProject(Project project) async {
    _projectBox.put(project.id ?? DateTime.now().toString(), project);
    _projects = _projectBox.values.toList();
    notifyListeners();
    await syncWithSupabase();
  }

  Future<void> syncWithSupabase() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    // 1) Subir cambios locales más recientes a Supabase
    for (var local in _projectBox.values) {
      final remote = await supabase
          .from('projects')
          .select()
          .eq('id', local.id ?? '')
          .maybeSingle();

      if (remote == null ||
          DateTime.parse(remote['updated_at']).isBefore(local.updatedAt)) {
        await supabase.from('projects').upsert(local.toMap());
      }
    }

    // 2) Bajar cambios de Supabase y guardar en Hive
    final response = await supabase.from('projects').select();
    for (var item in response) {
      final project = Project.fromMap(item);
      _projectBox.put(project.id, project);
    }

    _projects = _projectBox.values.toList();
    notifyListeners();
  }
}
