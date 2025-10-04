import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      final res = await auth.signIn(
                          _emailCtrl.text.trim(), _passCtrl.text.trim());
                      setState(() {
                        _loading = false;
                      });
                      if (res != null) {
                        setState(() {
                          _error = res;
                        });
                      } else {
                        // Login OK
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => const HomeScreen()));
                      }
                    },
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Ingresar'),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const RegisterScreen()));
                },
                child: const Text('Crear cuenta'))
          ],
        ),
      ),
    );
  }
}
