import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    cargarNotificaciones();
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
      appBar: AppBar(title: Text('Notificaciones')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : notificaciones == null || notificaciones!.isEmpty
          ? Center(child: Text('No hay notificaciones'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notificaciones!.length,
              itemBuilder: (ctx, i) {
                final n = notificaciones![i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(n['titulo'] ?? 'Sin título'),
                    subtitle: Text(n['mensaje'] ?? ''),
                    trailing: Text(n['fecha'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
