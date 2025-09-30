import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  List<dynamic>? gastos;
  List<dynamic>? pagos;
  List<dynamic>? multas;
  List<dynamic>? reservas;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarFinanzas();
  }

  Future<void> cargarFinanzas() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final resGastos = await api.fetchGastos();
      final resPagos = await api.fetchPagos();
      final resMultas = await api.fetchMultas();
      final resReservas = await api.fetchReservas();
      setState(() {
        gastos = resGastos;
        pagos = resPagos;
        multas = resMultas;
        reservas = resReservas;
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
                item['descripcion'] ??
                    item['motivo'] ??
                    item['concepto'] ??
                    'Sin descripción',
              ),
              subtitle: Text(subtitle(item)),
              trailing: Text(
                'Monto: ${item['monto'] ?? item['monto_pagado'] ?? item['costo_total'] ?? ''}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finanzas')),
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
                    'Gastos',
                    gastos,
                    (item) => 'Fecha: ${item['fecha_emision'] ?? ''}',
                  ),
                  buildList(
                    'Pagos',
                    pagos,
                    (item) => 'Fecha: ${item['fecha_pago'] ?? ''}',
                  ),
                  buildList(
                    'Multas',
                    multas,
                    (item) => 'Motivo: ${item['motivo'] ?? ''}',
                  ),
                  buildList(
                    'Reservas',
                    reservas,
                    (item) => 'Fecha: ${item['fecha_reserva'] ?? ''}',
                  ),
                ],
              ),
            ),
    );
  }
}
