import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/avisos_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/mantenimiento_screen.dart';
import 'screens/seguridad_screen.dart';
import 'screens/finanzas_screen.dart';
import 'screens/condominio_screen.dart';
import 'screens/auditoria_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'config/api_config.dart';
import 'services/api_service.dart';
import 'services/emulator_network_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar verificaciones de conectividad
  _initializeApp();
  runApp(const AppRoot());
}

Future<void> _initializeApp() async {
  try {
    print('🚀 Iniciando Smart Login App...');
    print('� Modo: ${ApiConfig.currentEnvironment}');
    print('� Emulador optimizado: ${ApiConfig.isEmulator}');

    // Ejecutar test de conectividad específico para emuladores
    print('🔍 Ejecutando test de conectividad para emulador...');
    final connectivityOk = await EmulatorNetworkService.runConnectivityTest();
    
    if (connectivityOk) {
      print('✅ Conectividad establecida correctamente');
      print('📡 URL Base: ${ApiConfig.baseUrl}');
    } else {
      print('⚠️ Problemas de conectividad detectados');
      print('🔧 Ejecutando diagnóstico automático...');
      await EmulatorNetworkService.diagnoseNetworkIssues();
    }

    // Verificar API básica
    final apiService = ApiService();
    await apiService.getWelcomeInfo();

    print('✅ Inicialización completada para emulador');
  } catch (e) {
    print('❌ Error en inicialización: $e');
    print('💡 Sugerencia: Verificar que el servidor Django esté ejecutándose');
    print('⚡ Comando: python manage.py runserver 0.0.0.0:8000');
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Condo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // --- CORRECCIÓN APLICADA ---
      // Se define la ruta inicial y se registran todas las rutas de la app.
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
          future: _hasToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Redirige a la pantalla principal si hay token, si no, al login.
            if (snapshot.data == true) {
              // Usamos un Widget post-frame para evitar errores de estado durante la construcción.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/main_menu');
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/login');
              });
            }
            // Muestra un loader mientras se decide la redirección.
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        '/login': (context) => const LoginScreen(),
        '/main_menu': (context) => const MainMenuScreen(),
        '/avisos': (context) => const AvisosScreen(),
        '/mantenimiento': (context) => const MantenimientoScreen(),
        '/seguridad': (context) => const SeguridadScreen(),
        '/finanzas': (context) => const FinanzasScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/condominio': (context) => const CondominioScreen(),
        '/auditoria': (context) => const AuditoriaScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
      },
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _showAllFunctions = false;

  final List<_MenuItem> _mainItems = [
    _MenuItem("Avisos", Icons.campaign_rounded, "/avisos"),
    _MenuItem("Mantenimiento", Icons.build_rounded, "/mantenimiento"),
    _MenuItem("Seguridad", Icons.security_rounded, "/seguridad"),
    _MenuItem("Finanzas", Icons.account_balance_wallet_rounded, "/finanzas"),
  ];

  final List<_MenuItem> _additionalItems = [
    _MenuItem("Perfil", Icons.person_rounded, "/perfil"),
    _MenuItem("Condominio", Icons.apartment_rounded, "/condominio"),
    _MenuItem("Auditoría", Icons.assignment_rounded, "/auditoria"),
    _MenuItem("Notificaciones", Icons.notifications_rounded, "/notificaciones"),
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (mounted) {
      // Navega a la pantalla de login y elimina todas las rutas anteriores.
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _testConnectivity() async {
    try {
      print('🔍 Iniciando test de conectividad...');
      final apiService = ApiService();

      // Mostrar dialog de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Probando conectividad...'),
            ],
          ),
        ),
      );

      await apiService.getWelcomeInfo();

      // Cerrar dialog de loading
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado exitoso
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Conectividad OK'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servidor: ${ApiConfig.currentEnvironment}'),
                Text('URL: ${ApiConfig.baseUrl}'),
                const Text('La conexión al servidor es exitosa.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar dialog de loading si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error de Conectividad'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Servidor: ${ApiConfig.currentEnvironment}'),
                Text('URL: ${ApiConfig.baseUrl}'),
                const SizedBox(height: 8),
                Text('Error: $e'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _testLogin() async {
    try {
      print('🔐 Iniciando test de login...');
      final apiService = ApiService();

      // Mostrar dialog de loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Probando login...'),
            ],
          ),
        ),
      );

      await apiService.login('admin', 'password');

      // Cerrar dialog de loading
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultado exitoso
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Test Login OK'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario: ${ApiConfig.testUsername}'),
                Text('Servidor: ${ApiConfig.currentEnvironment}'),
                const Text('El login de prueba funciona correctamente.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar dialog de loading si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Error en Test Login'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario: ${ApiConfig.testUsername}'),
                Text('Servidor: ${ApiConfig.currentEnvironment}'),
                const SizedBox(height: 8),
                Text('Error: $e'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Condo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Funciones Principales',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _mainItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(_mainItems[index]);
              },
            ),
            const SizedBox(height: 24),
            Card(
              child: ExpansionTile(
                title: const Text('Más Funciones'),
                leading: const Icon(Icons.apps),
                initiallyExpanded: _showAllFunctions,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _showAllFunctions = expanded;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                      itemCount: _additionalItems.length,
                      itemBuilder: (context, index) {
                        return _buildMenuItem(_additionalItems[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botón de diagnóstico para pruebas
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Herramientas de Diagnóstico',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Servidor: ${ApiConfig.currentEnvironment}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'URL: ${ApiConfig.baseUrl}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _testConnectivity,
                            icon: const Icon(Icons.wifi_find),
                            label: const Text('Test Conectividad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _testLogin,
                            icon: const Icon(Icons.login),
                            label: const Text('Test Login'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildMenuItem(_MenuItem item) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToScreen(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODO DE NAVEGACIÓN CORREGIDO ---
  void _navigateToScreen(String route) {
    // Usa `pushNamed` para navegar a la ruta definida en MaterialApp.
    Navigator.of(context).pushNamed(route);
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;

  _MenuItem(this.title, this.icon, this.route);
}
