
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'dart:convert';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // La URL base ahora apunta a la raíz de la API, como debe ser.
  static const String baseUrl =
      'https://smart-condominium-backend-cg7l.onrender.com/api';

  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;
  String _selectedRole = 'admin';

  final Map<String, Map<String, String>> _testUsers = {
    'admin': {'username': 'admin', 'password': 'admin123'},
    'residente1': {'username': 'residente1', 'password': 'password123'},
    'seguridad1': {'username': 'seguridad1', 'password': 'password123'},
    'mantenimiento1': {'username': 'mantenimiento1', 'password': 'password123'},
  };

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (_userCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese usuario y contraseña.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Lógica de login unificada: SIEMPRE va contra el backend.
      final uri = Uri.parse('$baseUrl/login/');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': _userCtrl.text.trim(),
          'password': _passCtrl.text,
        }),
      );

      if (res.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final token = (data['token'] as String?)?.trim();
        
        // El backend no devuelve el rol en el login, no es necesario guardarlo aquí.
        // final userRole = data['user']?['role'] ?? 'residente1';

        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          // Opcional: guardar el username para mostrarlo en el perfil.
          await prefs.setString('username', _userCtrl.text.trim());

          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            (route) => false,
          );
          return;
        }
      }

      // Si el status code no es 200 o no hay token, muestra error.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Smart Condo',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Autocompletar con Usuarios de Prueba', // Texto cambiado para mayor claridad
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: 'admin',
                          child: Text('👨‍💼 Administrador'),
                        ),
                        const DropdownMenuItem(
                          value: 'residente1',
                          child: Text('🏠 Residente'),
                        ),
                        const DropdownMenuItem(
                          value: 'seguridad1',
                          child: Text('🔒 Seguridad'),
                        ),
                        const DropdownMenuItem(
                          value: 'mantenimiento1',
                          child: Text(
                            '🔧 Mantenimiento',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                            _userCtrl.text = _testUsers[value]!['username']!;
                            _passCtrl.text = _testUsers[value]!['password']!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Iniciar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}