import 'package:flutter/material.dart';
import '../services/group_service.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';

import 'join_group_screen.dart'; // 👈 importa la pantalla de unirse

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupService groupService = GroupService();
  final TextEditingController ctrl = TextEditingController();
  List<Map<String, dynamic>> groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (provider.currentUserId == null) return;

    final res = await groupService.getUserGroups(provider.currentUserId!);
    setState(() {
      groups = res;
    });
  }

  Future<void> _createGroup() async {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    if (provider.currentUserId == null) return;

    await groupService.createGroup(ctrl.text, provider.currentUserId!);
    ctrl.clear();
    _loadGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grupos")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (_, index) {
                final g = groups[index];
                return ListTile(
                  title: Text(g['groups']['name']),
                  onTap: () {
                    final provider =
                        Provider.of<TaskProvider>(context, listen: false);
                    provider.setGroup(g['group_id']);
                    Navigator.pop(context); // vuelve a Home
                  },
                );
              },
            ),
          ),
          // 🔹 Botón para unirse a grupo (solo uno)
          ListTile(
            title: const Text("Unirse a grupo"),
            trailing: const Icon(Icons.group_add),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
              );
              // 👇 Al volver, recargamos grupos
              _loadGroups();
            },
          ),
          // 🔹 Crear nuevo grupo
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                      hintText: "Nuevo grupo",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _createGroup,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
