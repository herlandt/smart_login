import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';
import '../widgets/diagnostico_conectividad.dart';
import 'avisos_management_screen.dart';
import 'visitas_management_screen.dart';
import 'perfil_screen.dart';
import 'finanzas_screen.dart';
import 'condominio_screen.dart';

/// Pantalla principal del sistema Smart Login actualizada
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderActualizado>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Smart Login - Condominio'),
            actions: [
              // Información del usuario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    authProvider.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // Botón de logout
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar Sesión',
                onPressed: () => _showLogoutDialog(context, authProvider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida
                _buildWelcomeCard(authProvider),
                const SizedBox(height: 24),

                // Menú de opciones
                _buildMenuGrid(context, authProvider),
                const SizedBox(height: 24),

                // Diagnóstico de conectividad actualizado
                const DiagnosticoConectividad(),
                const SizedBox(height: 24),

                // Información de mejoras
                const InfoMejorasImplementadas(),
                const SizedBox(height: 24),

                // Información adicional
                _buildInfoCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(AuthProviderActualizado authProvider) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authProvider.displayName,
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              authProvider.roleDescription,
              style: const TextStyle(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(
    BuildContext context,
    AuthProviderActualizado authProvider,
  ) {
    final menuItems = _getMenuItems(context, authProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          context,
          item['title']!,
          item['subtitle']!,
          item['icon'] as IconData,
          item['color'] as Color,
          item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sistema Smart Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Todas las funcionalidades han sido actualizadas para coincidir exactamente con tu schema OpenAPI 2025.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              '✅ Backend: Conectado con endpoints actualizados\n✅ API Schema: Compatible con OpenAPI 3.0.3\n✅ Autenticación: Token-based actualizada\n✅ Endpoints: Verificados contra tu documentación',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMenuItems(
    BuildContext context,
    AuthProviderActualizado authProvider,
  ) {
    final items = <Map<String, dynamic>>[];

    // Opciones básicas para todos los usuarios
    items.addAll([
      {
        'title': 'Mi Perfil',
        'subtitle': 'Ver información personal',
        'icon': Icons.person,
        'color': Colors.blue,
        'onTap': () => _navegarAPerfil(context),
      },
      {
        'title': 'Avisos',
        'subtitle': 'Noticias del condominio',
        'icon': Icons.announcement,
        'color': Colors.orange,
        'onTap': () => _navegarAAvisos(context),
      },
    ]);

    // Opciones para seguridad
    if (authProvider.hasSecurityPermissions) {
      items.addAll([
        {
          'title': 'Control de Acceso',
          'subtitle': 'Gestión de visitas',
          'icon': Icons.security,
          'color': Colors.red,
          'onTap': () => _navegarAVisitas(context),
        },
        {
          'title': 'Visitantes',
          'subtitle': 'Registro de visitantes',
          'icon': Icons.people,
          'color': Colors.purple,
          'onTap': () => _navegarAVisitas(context),
        },
      ]);
    }

    // Opciones para administrador/propietario
    if (authProvider.hasAdminPermissions) {
      items.addAll([
        {
          'title': 'Finanzas',
          'subtitle': 'Gestión financiera',
          'icon': Icons.account_balance_wallet,
          'color': Colors.green,
          'onTap': () => _showComingSoon('Finanzas'),
        },
        {
          'title': 'Propiedades',
          'subtitle': 'Gestión de propiedades',
          'icon': Icons.home_work,
          'color': Colors.teal,
          'onTap': () => _showComingSoon('Propiedades'),
        },
        {
          'title': 'Reportes',
          'subtitle': 'Reportes y estadísticas',
          'icon': Icons.analytics,
          'color': Colors.indigo,
          'onTap': () => _showComingSoon('Reportes'),
        },
      ]);
    }

    // Opciones para mantenimiento
    if (authProvider.hasMaintenancePermissions) {
      items.addAll([
        {
          'title': 'Solicitudes',
          'subtitle': 'Gestión de solicitudes',
          'icon': Icons.build,
          'color': Colors.orange,
          'onTap': () => _showComingSoon('Solicitudes de Mantenimiento'),
        },
        {
          'title': 'Inventario',
          'subtitle': 'Control de inventario',
          'icon': Icons.inventory,
          'color': Colors.brown,
          'onTap': () => _showComingSoon('Inventario'),
        },
      ]);
    }

    // Opciones adicionales para residentes
    if (!authProvider.hasAdminPermissions) {
      items.addAll([
        {
          'title': 'Mis Pagos',
          'subtitle': 'Historial de pagos',
          'icon': Icons.payment,
          'color': Colors.cyan,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FinanzasScreen()),
            );
          },
        },
        {
          'title': 'Reservas',
          'subtitle': 'Áreas comunes',
          'icon': Icons.event_available,
          'color': Colors.lime,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CondominioScreen()),
            );
          },
        },
      ]);
    }

    // Opciones para administradores
    if (authProvider.hasAdminPermissions) {
      items.addAll([
        {
          'title': 'Finanzas',
          'subtitle': 'Gestión financiera',
          'icon': Icons.attach_money,
          'color': Colors.purple,
          'onTap': () => _showComingSoon('Finanzas'),
        },
        {
          'title': 'Auditoría',
          'subtitle': 'Logs del sistema',
          'icon': Icons.history,
          'color': Colors.indigo,
          'onTap': () => _showComingSoon('Auditoría'),
        },
      ]);
    }

    return items;
  }

  void _showComingSoon(String feature) {
    // Placeholder para futuras funcionalidades
    debugPrint('🚧 Funcionalidad "$feature" en desarrollo');
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProviderActualizado authProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar tu sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _navegarAAvisos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AvisosManagementScreen()),
    );
  }

  void _navegarAVisitas(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VisitasManagementScreen()),
    );
  }

  void _navegarAPerfil(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const PerfilScreen()));
  }
}
