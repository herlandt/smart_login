import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CondominioScreen extends StatefulWidget {
  const CondominioScreen({super.key});

  @override
  State<CondominioScreen> createState() => _CondominioScreenState();
}

class _CondominioScreenState extends State<CondominioScreen> {
  List<dynamic>? propiedades;
  List<dynamic>? areasComunes;
  List<dynamic>? avisos;
  List<dynamic>? reglas;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarCondominio();
  }

  Future<void> cargarCondominio() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final resPropiedades = await api.fetchPropiedades();
      final resAreasComunes = await api.fetchAreasComunes();
      final resAvisos = await api.get('/condominio/avisos/');
      final resReglas = await api.fetchReglas();
      setState(() {
        propiedades = resPropiedades;
        areasComunes = resAreasComunes;
        avisos = resAvisos['data'] ?? [];
        reglas = resReglas;
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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('No hay $title registrados'),
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
                    item['numero_casa'] ??
                    item['titulo'] ??
                    item['descripcion'] ??
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
      appBar: AppBar(title: Text('Condominio')),
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
                    'Propiedades',
                    propiedades,
                    (item) => 'Casa: ${item['numero_casa'] ?? ''}',
                  ),
                  buildList(
                    'Áreas Comunes',
                    areasComunes,
                    (item) => 'Tipo: ${item['tipo'] ?? ''}',
                  ),
                  buildList(
                    'Avisos',
                    avisos,
                    (item) => 'Fecha: ${item['fecha'] ?? ''}',
                  ),
                  buildList(
                    'Reglas',
                    reglas,
                    (item) => 'Descripción: ${item['descripcion'] ?? ''}',
                  ),
                ],
              ),
            ),
    );
  }
}
