import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';

class QuickLoginScreen extends StatelessWidget {
  const QuickLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderActualizado>(context);

    // Credenciales del prompt de desarrollo móvil
    final Map<String, Map<String, String>> testCredentials = {
      'admin': {
        'username': 'admin',
        'password': 'admin123',
        'description': 'PROPIETARIO/ADMIN - Acceso completo al sistema',
      },
      'residente1': {
        'username': 'residente1',
        'password': 'isaelOrtiz2',
        'description': 'RESIDENTE - Pagos, reservas, visitas, mantenimiento',
      },
      'propietario1': {
        'username': 'propietario1',
        'password': 'joseGarcia3',
        'description':
            'RESIDENTE/PROPIETARIO - Todas las funciones de residente',
      },
      'inquilino1': {
        'username': 'inquilino1',
        'password': 'anaLopez4',
        'description': 'RESIDENTE/INQUILINO - Funciones básicas de residente',
      },
      'seguridad1': {
        'username': 'seguridad1',
        'password': 'guardia123',
        'description': 'SEGURIDAD - Control de acceso, visitantes, monitoreo',
      },
      'mantenimiento1': {
        'username': 'mantenimiento1',
        'password': 'mant456',
        'description': 'MANTENIMIENTO - Gestión de solicitudes y trabajos',
      },
      'invitado1': {
        'username': 'invitado1',
        'password': 'invCarlos5',
        'description': 'RESIDENTE/INVITADO - Acceso temporal limitado',
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Quick Login - Smart Condominium'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Usuarios de Prueba Disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona un usuario para hacer login automático:',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (authProvider.isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Iniciando sesión...'),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                itemCount: testCredentials.length,
                itemBuilder: (context, index) {
                  final key = testCredentials.keys.elementAt(index);
                  final creds = testCredentials[key]!;

                  Color cardColor;
                  IconData roleIcon;

                  switch (key) {
                    case 'admin':
                      cardColor = Colors.purple.shade100;
                      roleIcon = Icons.admin_panel_settings;
                      break;
                    case 'seguridad1':
                      cardColor = Colors.orange.shade100;
                      roleIcon = Icons.security;
                      break;
                    case 'mantenimiento1':
                      cardColor = Colors.brown.shade100;
                      roleIcon = Icons.build;
                      break;
                    default:
                      cardColor = Colors.green.shade100;
                      roleIcon = Icons.home;
                  }

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cardColor.withOpacity(0.3),
                        child: Icon(roleIcon, color: Colors.black87),
                      ),
                      title: Text(
                        creds['username']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        creds['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: authProvider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login, color: Colors.blue),
                      onTap: authProvider.isLoading
                          ? null
                          : () => _quickLogin(
                              context,
                              creds['username']!,
                              creds['password']!,
                            ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estos son usuarios de prueba. En producción, los usuarios deberán ingresar sus credenciales manualmente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickLogin(
    BuildContext context,
    String username,
    String password,
  ) async {
    final authProvider = Provider.of<AuthProviderActualizado>(
      context,
      listen: false,
    );

    try {
      final success = await authProvider.login(username, password);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Login exitoso como $username!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navegar de vuelta al home
        Navigator.pop(context);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de autenticación para $username'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
