import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Guardar proyecto en Supabase
  Future<void> addProject(Project project) async {
    await supabase.from('projects').insert({
      'name': project.name,
      'description': project.description,
      'deadline': project.deadline.toIso8601String(),
    });
  }

  // Obtener proyectos desde Supabase
  Future<List<Project>> getProjects() async {
    final response = await supabase.from('projects').select();
    return (response as List).map((e) => Project.fromMap(e)).toList();
  }

  // Eliminar proyecto en Supabase
  Future<void> deleteProject(int id) async {
    await supabase.from('projects').delete().eq('id', id);
  }
}
