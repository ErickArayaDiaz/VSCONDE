// lib/services/group_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final _supabase = Supabase.instance.client;

  Future<String> createGroup(String name, String userId) async {
    final res = await _supabase
        .from('groups')
        .insert({
          'name': name,
        })
        .select()
        .single();

    final groupId = res['id'];

    // Agregar creador como admin
    await _supabase.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'admin',
    });

    return groupId;
  }

  Future<List<Map<String, dynamic>>> getUserGroups(String userId) async {
    final res = await _supabase
        .from('group_members')
        .select('group_id, groups(name)')
        .eq('user_id', userId);

    // ✅ castear explícitamente a List<Map<String, dynamic>>
    final list =
        (res as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return list;
  }

  Future<void> addMember(String groupId, String userId,
      {String role = 'member'}) async {
    await _supabase.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': role,
    });
  }
}
