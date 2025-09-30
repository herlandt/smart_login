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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot());
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
      home: FutureBuilder<bool>(
        future: _hasToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data! ? const MainMenuScreen() : const LoginScreen();
        },
      ),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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

  void _navigateToScreen(String route) {
    Widget screen;
    switch (route) {
      case "/avisos":
        screen = const AvisosScreen();
        break;
      case "/perfil":
        screen = const PerfilScreen();
        break;
      case "/mantenimiento":
        screen = const MantenimientoScreen();
        break;
      case "/seguridad":
        screen = const SeguridadScreen();
        break;
      case "/finanzas":
        screen = const FinanzasScreen();
        break;
      case "/condominio":
        screen = const CondominioScreen();
        break;
      case "/auditoria":
        screen = const AuditoriaScreen();
        break;
      case "/notificaciones":
        screen = const NotificacionesScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;

  _MenuItem(this.title, this.icon, this.route);
}
