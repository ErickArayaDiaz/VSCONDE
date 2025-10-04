import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Registro (email/password). Devuelve el user map si OK
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  // Login
  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth
        .signInWithPassword(email: email, password: password);
  }

  // Logout
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Obtener info del user desde la tabla users (si la creaste)
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final res =
        await client.from('users').select().eq('id', userId).maybeSingle();
    if (res == null) return null;
    return res as Map<String, dynamic>;
  }
}
