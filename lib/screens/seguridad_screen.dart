import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SeguridadScreen extends StatefulWidget {
  const SeguridadScreen({super.key});

  @override
  State<SeguridadScreen> createState() => _SeguridadScreenState();
}

class _SeguridadScreenState extends State<SeguridadScreen> {
  List<dynamic>? visitas;
  List<dynamic>? vehiculos;
  List<dynamic>? eventos;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarSeguridad();
  }

  Future<void> cargarSeguridad() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final resVisitas = await api.fetchVisitas();
      final resVehiculos = await api.fetchVehiculos();
      final resEventos = await api.fetchEventosSeguridad();
      setState(() {
        visitas = resVisitas;
        vehiculos = resVehiculos;
        eventos = resEventos;
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

  Widget buildList(
    String title,
    List<dynamic>? items,
    String Function(dynamic) subtitle,
  ) {
    if (items == null) return const SizedBox.shrink();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No hay registros'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map(
          (item) => Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                item['nombre'] ??
                    item['placa'] ??
                    item['tipo_evento'] ??
                    'Sin nombre',
              ),
              subtitle: Text(subtitle(item)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seguridad')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildList(
                    'Visitas',
                    visitas,
                    (item) => 'Ingreso: ${item['ingreso_real'] ?? ''}',
                  ),
                  buildList(
                    'Vehículos',
                    vehiculos,
                    (item) => 'Placa: ${item['placa'] ?? ''}',
                  ),
                  buildList(
                    'Eventos',
                    eventos,
                    (item) => 'Fecha: ${item['fecha'] ?? ''}',
                  ),
                ],
              ),
            ),
    );
  }
}
