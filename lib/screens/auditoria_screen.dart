import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuditoriaScreen extends StatefulWidget {
  const AuditoriaScreen({super.key});

  @override
  State<AuditoriaScreen> createState() => _AuditoriaScreenState();
}

class _AuditoriaScreenState extends State<AuditoriaScreen> {
  List<dynamic>? historial;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarAuditoria();
  }

  Future<void> cargarAuditoria() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await ApiService().fetchAuditoriaHistorial();
      setState(() {
        historial = res;
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
      appBar: AppBar(title: Text('Auditoría')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : historial == null || historial!.isEmpty
          ? Center(child: Text('No hay historial de auditoría'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historial!.length,
              itemBuilder: (ctx, i) {
                final h = historial![i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(h['accion'] ?? 'Sin acción'),
                    subtitle: Text(h['descripcion'] ?? ''),
                    trailing: Text(h['fecha'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
