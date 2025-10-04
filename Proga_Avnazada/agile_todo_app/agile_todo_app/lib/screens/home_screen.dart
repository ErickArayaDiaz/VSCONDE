import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agile ToDo - Home'),
        actions: [
          IconButton(
              onPressed: () async {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido, ${auth.localUser?.email ?? 'Usuario'}'),
            const SizedBox(height: 16),
            const Text(
                'Aquí irá la lista de grupos y proyectos (más adelante).'),
          ],
        ),
      ),
    );
  }
}
