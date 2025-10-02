import 'package:flutter/material.dart';
import '../services/api_service_actualizado.dart';

/// Pantalla de prueba para verificar que la autenticación funciona
class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _result = '';

  Future<void> _testAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      debugPrint('🔐 Intentando autenticación con: $username');

      final apiService = ApiServiceActualizado();
      final response = await apiService.login(username, password);

      debugPrint('✅ Respuesta de login exitosa: $response');

      setState(() {
        _result =
            'LOGIN EXITOSO\n\n'
            'Token: ${response['token'] ?? 'No disponible'}\n'
            'Usuario: ${response['user']?['username'] ?? 'No disponible'}\n'
            'Rol: ${response['user']?['rol'] ?? 'No disponible'}\n'
            'Permisos: ${response['user']?['permissions'] ?? 'No disponibles'}';
      });

      // Probar obtener perfil si el login fue exitoso
      if (response['token'] != null) {
        await _testProfile();
      }
    } catch (e) {
      debugPrint('❌ Error en login: $e');
      setState(() {
        _result = 'ERROR EN LOGIN\n\n$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testProfile() async {
    try {
      debugPrint('👤 Obteniendo perfil de usuario...');

      final apiService = ApiServiceActualizado();
      final profileResponse = await apiService.getPerfilUsuario();

      debugPrint('✅ Respuesta de perfil exitosa: $profileResponse');

      setState(() {
        _result +=
            '\n\n--- PERFIL ---\n'
            'ID: ${profileResponse['id'] ?? 'No disponible'}\n'
            'Username: ${profileResponse['username'] ?? 'No disponible'}\n'
            'Email: ${profileResponse['email'] ?? 'No disponible'}\n'
            'Rol: ${profileResponse['rol'] ?? 'No disponible'}\n'
            'Activo: ${profileResponse['is_active'] ?? 'No disponible'}';
      });
    } catch (e) {
      debugPrint('❌ Error al obtener perfil: $e');
      setState(() {
        _result += '\n\nERROR AL OBTENER PERFIL\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Autenticación'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          hintText: 'Ingresa tu usuario',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Ingresa tu contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testAuth,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Probar Autenticación'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_result.isNotEmpty)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Text(
                          _result,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
