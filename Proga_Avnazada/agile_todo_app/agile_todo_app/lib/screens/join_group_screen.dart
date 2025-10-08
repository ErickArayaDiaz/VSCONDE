// lib/screens/join_group_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/task_provider.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _groupNameCtrl = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _joinGroup() async {
    final groupName = _groupNameCtrl.text.trim();
    if (groupName.isEmpty) {
      setState(() => _message = "⚠️ Ingresa el nombre del grupo");
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Buscar el grupo por nombre
      final groups = await Supabase.instance.client
          .from('groups')
          .select('id')
          .eq('name', groupName);

      if (groups.isEmpty) {
        setState(() => _message = "❌ No existe un grupo con ese nombre");
        return;
      }

      final groupId = groups.first['id'] as String;

      // Insertar en group_members
      await Supabase.instance.client.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': 'member',
      });

      // ✅ Actualizar el TaskProvider con el nuevo grupo
      final provider = context.read<TaskProvider>();
      provider.setGroup(groupId);

      setState(() => _message = "✅ Te uniste al grupo $groupName");
    } catch (e) {
      setState(() => _message = "❌ Error al unirse: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unirse a Grupo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre del Grupo",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _joinGroup,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.group_add),
              label: Text(_loading ? "Uniéndose..." : "Unirse"),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.contains("✅") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
