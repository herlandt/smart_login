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
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarFinanzas();
  }

  Future<void> cargarFinanzas() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final futures = await Future.wait([
        api.fetchGastos().catchError((e) => <dynamic>[]),
        api.fetchPagos().catchError((e) => <dynamic>[]),
        api.fetchMultas().catchError((e) => <dynamic>[]),
      ]);

      if (mounted) {
        setState(() {
          gastos = futures[0];
          pagos = futures[1];
          multas = futures[2];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finanzas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Gastos', icon: Icon(Icons.receipt)),
              Tab(text: 'Pagos', icon: Icon(Icons.payment)),
              Tab(text: 'Multas', icon: Icon(Icons.warning)),
            ],
          ),
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
                      onPressed: cargarFinanzas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            : TabBarView(
                children: [
                  _buildGastosTab(),
                  _buildPagosTab(),
                  _buildMultasTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildGastosTab() {
    return RefreshIndicator(
      onRefresh: cargarFinanzas,
      child: gastos == null || gastos!.isEmpty
          ? const Center(child: Text('No hay gastos'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: gastos!.length,
              itemBuilder: (ctx, i) {
                final gasto = gastos![i];
                final monto = gasto['monto']?.toString() ?? '0';
                final descripcion = gasto['descripcion'] ?? 'Sin descripción';
                final fecha = gasto['fecha_emision'] ?? '';
                final estado = gasto['estado'] ?? 'Pendiente';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.receipt, color: Colors.orange),
                    title: Text(
                      'Bs. $monto',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(descripcion),
                        Text('Fecha: $fecha'),
                        Text('Estado: $estado'),
                      ],
                    ),
                    trailing: gasto['pagado'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => procesarPago(gasto),
                            child: const Text('Pagar'),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPagosTab() {
    return RefreshIndicator(
      onRefresh: cargarFinanzas,
      child: pagos == null || pagos!.isEmpty
          ? const Center(child: Text('No hay pagos registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pagos!.length,
              itemBuilder: (ctx, i) {
                final pago = pagos![i];
                final monto = pago['monto']?.toString() ?? '0';
                final fecha = pago['fecha_pago'] ?? '';
                final metodo = pago['metodo_pago'] ?? 'No especificado';
                final estado = pago['estado'] ?? 'Procesado';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.payment, color: Colors.green),
                    title: Text(
                      'Bs. $monto',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha: $fecha'),
                        Text('Método: $metodo'),
                        Text('Estado: $estado'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => mostrarComprobante(pago),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMultasTab() {
    return RefreshIndicator(
      onRefresh: cargarFinanzas,
      child: multas == null || multas!.isEmpty
          ? const Center(child: Text('No hay multas'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: multas!.length,
              itemBuilder: (ctx, i) {
                final multa = multas![i];
                final monto = multa['monto']?.toString() ?? '0';
                final motivo = multa['motivo'] ?? 'No especificado';
                final fecha = multa['fecha_multa'] ?? '';
                final estado = multa['estado'] ?? 'Pendiente';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(
                      'Bs. $monto',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Motivo: $motivo'),
                        Text('Fecha: $fecha'),
                        Text('Estado: $estado'),
                      ],
                    ),
                    trailing: multa['pagada'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => pagarMulta(multa),
                            child: const Text('Pagar'),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> procesarPago(Map<String, dynamic> gasto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Realizar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Monto: Bs. ${gasto['monto']?.toString() ?? '0'}'),
            Text('Descripción: ${gasto['descripcion'] ?? ''}'),
            const SizedBox(height: 16),
            const Text('¿Confirmar pago?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pagar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService().post('api/finanzas/gastos/${gasto['id']}/pagar/', {
          'metodo_pago': 'transferencia',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pago procesado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          cargarFinanzas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar pago: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> pagarMulta(Map<String, dynamic> multa) async {
    try {
      await ApiService().post('api/finanzas/multas/${multa['id']}/pagar/', {
        'metodo_pago': 'transferencia',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Multa pagada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        cargarFinanzas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al pagar multa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void mostrarComprobante(Map<String, dynamic> pago) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando comprobante del pago ${pago['id']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
