import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = true;
  LocalUser? localUser;
  Box<LocalUser>? _box;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = Hive.box<LocalUser>('local_user');
    // Intentar restaurar user local
    if (_box!.isNotEmpty) {
      localUser = _box!.getAt(0);
    } else {
      // Intentar obtener user desde Supabase session
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null && session.user != null) {
        final uid = session.user!.id;
        final profile = await SupabaseService.getProfile(uid);
        if (profile != null) {
          localUser = LocalUser.fromMap(profile);
          await _saveLocal(localUser!);
        } else {
          // si no hay profile en tabla, crear local básico
          localUser = LocalUser(
            id: session.user!.id,
            email: session.user!.email ?? '',
            name: '',
            createdAt: DateTime.now(),
          );
          await _saveLocal(localUser!);
        }
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _saveLocal(LocalUser user) async {
    await _box!.clear();
    await _box!.add(user);
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final resp = await SupabaseService.signIn(email, password);
      if (resp.session == null && resp.user == null) {
        return 'Credenciales inválidas';
      }
      final user = resp.user!;
      // Intenta obtener profile de DB
      final profile = await SupabaseService.getProfile(user.id);
      if (profile != null) {
        localUser = LocalUser.fromMap(profile);
      } else {
        localUser = LocalUser(
          id: user.id,
          email: user.email ?? '',
          name: '',
          createdAt: DateTime.now(),
        );
      }
      await _saveLocal(localUser!);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password, {String? name}) async {
    try {
      final resp = await SupabaseService.signUp(email, password);
      if (resp.user == null) {
        return 'No se pudo crear la cuenta';
      }
      final user = resp.user!;
      // Opcional: crear profile en tabla 'users' (si la tabla la creaste)
      final profileMap = {
        'id': user.id,
        'email': user.email,
        'name': name ?? '',
        'created_at': DateTime.now().toIso8601String(),
      };
      // intentar insertar en tabla users
      try {
        await Supabase.instance.client
            .from('users')
            .insert(profileMap)
            .execute();
      } catch (_) {
        // si falla, no es crítico; seguimos
      }

      localUser = LocalUser.fromMap(profileMap);
      await _saveLocal(localUser!);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    localUser = null;
    await _box!.clear();
    notifyListeners();
  }
}
