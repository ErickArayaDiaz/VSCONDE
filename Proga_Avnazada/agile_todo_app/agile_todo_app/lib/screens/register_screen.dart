// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      final res = await auth.signUp(
                          _emailCtrl.text.trim(), _passCtrl.text.trim(),
                          name: _nameCtrl.text.trim());
                      setState(() {
                        _loading = false;
                      });
                      if (res != null) {
                        setState(() {
                          _error = res;
                        });
                      } else {
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
