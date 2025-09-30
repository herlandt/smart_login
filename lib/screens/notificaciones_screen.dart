import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/api_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<dynamic>? notificaciones;
  bool loading = true;
  String? error;
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    configurarNotificaciones();
    cargarNotificaciones();
  }

  Future<void> configurarNotificaciones() async {
    try {
      // Solicitar permisos
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Obtener token del dispositivo
        final token = await messaging.getToken();
        setState(() {
          deviceToken = token;
        });

        // Registrar token en el backend
        if (token != null) {
          await ApiService().post('/notificaciones/registrar-dispositivo/', {
            'token': token,
            'platform': 'android', // o 'ios' según la plataforma
          });
        }

        // Configurar handler para notificaciones en foreground
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message.notification?.body ?? 'Nueva notificación',
                ),
                backgroundColor: Colors.blue,
              ),
            );
            cargarNotificaciones(); // Recargar notificaciones
          }
        });
      }
    } catch (e) {
      // Error configurando notificaciones
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error configurando notificaciones: $e')),
        );
      }
    }
  }

  Future<void> cargarNotificaciones() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await ApiService().fetchNotificaciones();
      setState(() {
        notificaciones = res;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarNotificaciones,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: cargarNotificaciones,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : notificaciones == null || notificaciones!.isEmpty
          ? const Center(child: Text('No hay notificaciones'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notificaciones!.length,
              itemBuilder: (ctx, i) {
                final notif = notificaciones![i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      notif['leida'] == true
                          ? Icons.mark_email_read
                          : Icons.mark_email_unread,
                      color: notif['leida'] == true ? Colors.grey : Colors.blue,
                    ),
                    title: Text(
                      notif['titulo'] ?? 'Sin título',
                      style: TextStyle(
                        fontWeight: notif['leida'] == true
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notif['mensaje'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          notif['fecha_creacion'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => marcarComoLeida(notif['id']),
                  ),
                );
              },
            ),
      floatingActionButton: deviceToken != null
          ? FloatingActionButton.extended(
              onPressed: () => mostrarInfoToken(),
              icon: const Icon(Icons.info),
              label: const Text('Token Info'),
            )
          : null,
    );
  }

  Future<void> marcarComoLeida(int notifId) async {
    try {
      await ApiService().post('/notificaciones/$notifId/marcar-leida/', {});
      cargarNotificaciones();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void mostrarInfoToken() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Token del Dispositivo'),
        content: SingleChildScrollView(
          child: Text(deviceToken ?? 'No disponible'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
