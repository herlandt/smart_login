import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import 'pasarela_pago_screen.dart';
import 'historial_pagos_screen.dart';
import 'pago_qr_screen.dart';

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

  // Para selección múltiple
  Set<int> gastosSeleccionados = {};
  Set<int> multasSeleccionadas = {};
  bool modoSeleccion = false;

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
          title: Text(
            modoSeleccion
                ? '${gastosSeleccionados.length + multasSeleccionadas.length} seleccionados'
                : 'Finanzas',
          ),
          actions: [
            if (modoSeleccion)
              IconButton(
                icon: const Icon(Icons.payment),
                onPressed: _pagarSeleccionados,
                tooltip: 'Pagar Seleccionados',
              ),
            if (modoSeleccion)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    modoSeleccion = false;
                    gastosSeleccionados.clear();
                    multasSeleccionadas.clear();
                  });
                },
                tooltip: 'Cancelar Selección',
              ),
            if (!modoSeleccion)
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorialPagosScreen(),
                    ),
                  );
                },
                tooltip: 'Historial de Pagos',
              ),
          ],
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
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!modoSeleccion)
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    modoSeleccion = true;
                  });
                },
                heroTag: "multi_select",
                child: const Icon(Icons.checklist),
                tooltip: 'Selección Múltiple',
              ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              onPressed: _mostrarPagoRapido,
              icon: const Icon(Icons.qr_code),
              label: const Text('Pago QR'),
              heroTag: "qr_payment",
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarPagoRapido() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Pago Rápido con QR',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Monto (Bs.)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (value) {
                  final monto = double.tryParse(value);
                  if (monto != null && monto > 0) {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PagoQRScreen(
                          monto: monto,
                          concepto: 'Pago rápido',
                          onPagoCompletado: (transaccion) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pago procesado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            cargarFinanzas();
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Implementar lógica para monto rápido
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Generar QR'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pagarSeleccionados() async {
    if (gastosSeleccionados.isEmpty && multasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay elementos seleccionados'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calcular monto total
    double montoTotal = 0.0;

    // Sumar gastos seleccionados
    if (gastosSeleccionados.isNotEmpty && gastos != null) {
      for (final gasto in gastos!) {
        if (gastosSeleccionados.contains(gasto['id']) &&
            gasto['pagado'] != true) {
          montoTotal += double.tryParse(gasto['monto'].toString()) ?? 0.0;
        }
      }
    }

    // Sumar multas seleccionadas
    if (multasSeleccionadas.isNotEmpty && multas != null) {
      for (final multa in multas!) {
        if (multasSeleccionadas.contains(multa['id']) &&
            multa['pagado'] != true) {
          montoTotal += double.tryParse(multa['monto'].toString()) ?? 0.0;
        }
      }
    }

    if (montoTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay deudas pendientes en la selección'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar confirmación
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago en Lote'),
        content: Text(
          'Se pagarán ${gastosSeleccionados.length} gastos y ${multasSeleccionadas.length} multas.\n\n'
          'Monto total: Bs. ${montoTotal.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Pagar Todo'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      // Navegar a la pasarela de pago
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasarelaPagoScreen(
            monto: montoTotal,
            concepto:
                'Pago en lote (${gastosSeleccionados.length + multasSeleccionadas.length} elementos)',
            descripcion: 'Pago múltiple de gastos y multas',
            onPagoCompletado: (transaccion) async {
              if (transaccion.estado == EstadoPago.exitoso) {
                try {
                  final api = ApiService();

                  // Pagar gastos en lote
                  if (gastosSeleccionados.isNotEmpty) {
                    await api.pagarGastosEnLote(
                      gastosSeleccionados.toList(),
                      metodoPago: transaccion.metodo.codigo,
                      referencia: transaccion.referencia,
                    );
                  }

                  // Pagar multas en lote
                  if (multasSeleccionadas.isNotEmpty) {
                    await api.pagarMultasEnLote(
                      multasSeleccionadas.toList(),
                      metodoPago: transaccion.metodo.codigo,
                      referencia: transaccion.referencia,
                    );
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pago en lote procesado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Salir del modo selección y recargar datos
                    setState(() {
                      modoSeleccion = false;
                      gastosSeleccionados.clear();
                      multasSeleccionadas.clear();
                    });

                    await cargarFinanzas();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error en pago en lote: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ),
      );
    }
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
                final estado = gasto['pagado'] == true ? 'Pagado' : 'Pendiente';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: modoSeleccion
                        ? Checkbox(
                            value: gastosSeleccionados.contains(gasto['id']),
                            onChanged: gasto['pagado'] == true
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        gastosSeleccionados.add(gasto['id']);
                                      } else {
                                        gastosSeleccionados.remove(gasto['id']);
                                      }
                                    });
                                  },
                          )
                        : const Icon(Icons.receipt, color: Colors.orange),
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
                        : modoSeleccion
                        ? null
                        : ElevatedButton(
                            onPressed: () => procesarPago(gasto),
                            child: const Text('Pagar'),
                          ),
                    onLongPress: !modoSeleccion && gasto['pagado'] != true
                        ? () {
                            setState(() {
                              modoSeleccion = true;
                              gastosSeleccionados.add(gasto['id']);
                            });
                          }
                        : null,
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
                final monto = pago['monto_pagado']?.toString() ?? '0';
                final fecha = pago['fecha_pago'] ?? '';
                final estado = pago['estado_pago'] ?? 'Procesado';

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
                final motivo = multa['concepto'] ?? 'No especificado';
                final fecha = multa['fecha_emision'] ?? '';
                final estado = multa['pagado'] == true ? 'Pagada' : 'Pendiente';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: modoSeleccion
                        ? Checkbox(
                            value: multasSeleccionadas.contains(multa['id']),
                            onChanged: multa['pagado'] == true
                                ? null
                                : (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        multasSeleccionadas.add(multa['id']);
                                      } else {
                                        multasSeleccionadas.remove(multa['id']);
                                      }
                                    });
                                  },
                          )
                        : const Icon(Icons.warning, color: Colors.red),
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
                    trailing: multa['pagado'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : modoSeleccion
                        ? null
                        : ElevatedButton(
                            onPressed: () => pagarMulta(multa),
                            child: const Text('Pagar'),
                          ),
                    onLongPress: !modoSeleccion && multa['pagado'] != true
                        ? () {
                            setState(() {
                              modoSeleccion = true;
                              multasSeleccionadas.add(multa['id']);
                            });
                          }
                        : null,
                  ),
                );
              },
            ),
    );
  }

  Future<void> procesarPago(Map<String, dynamic> gasto) async {
    final monto = num.tryParse(gasto['monto'].toString())?.toDouble() ?? 0.0;
    final concepto =
        'Pago de gasto: ${gasto['descripcion'] ?? 'Sin descripción'}';

    // Navegar a la pasarela de pago
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasarelaPagoScreen(
          monto: monto,
          concepto: concepto,
          descripcion: gasto['descripcion'],
          onPagoCompletado: (transaccion) async {
            if (transaccion.estado == EstadoPago.exitoso) {
              try {
                // Registrar el pago en el backend con datos completos
                await ApiService().pagarGasto(
                  gasto['id'],
                  montoPagado: transaccion.monto,
                  metodoPago: transaccion.metodo.codigo,
                  referencia: transaccion.referencia,
                );

                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Pago procesado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Actualización optimista: marcar como pagado en la UI
                  setState(() {
                    gasto['pagado'] = true;
                  });

                  // Recargar la lista de pagos
                  final api = ApiService();
                  final nuevosPagos = await api.fetchPagos().catchError(
                    (e) => pagos ?? <dynamic>[],
                  );
                  setState(() {
                    pagos = nuevosPagos;
                  });
                }
              } catch (e) {
                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al registrar pago: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> pagarMulta(Map<String, dynamic> multa) async {
    final monto = num.tryParse(multa['monto'].toString())?.toDouble() ?? 0.0;
    final concepto = 'Pago de multa: ${multa['concepto'] ?? 'Sin concepto'}';

    // Navegar a la pasarela de pago
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasarelaPagoScreen(
          monto: monto,
          concepto: concepto,
          descripcion: multa['concepto'],
          onPagoCompletado: (transaccion) async {
            if (transaccion.estado == EstadoPago.exitoso) {
              try {
                // Registrar el pago en el backend con datos completos
                await ApiService().pagarMulta(
                  multa['id'],
                  montoPagado: transaccion.monto,
                  metodoPago: transaccion.metodo.codigo,
                  referencia: transaccion.referencia,
                );

                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Multa pagada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Actualización optimista: marcar como pagada en la UI
                  setState(() {
                    multa['pagado'] = true;
                  });

                  // Recargar la lista de pagos
                  final api = ApiService();
                  final nuevosPagos = await api.fetchPagos().catchError(
                    (e) => pagos ?? <dynamic>[],
                  );
                  setState(() {
                    pagos = nuevosPagos;
                  });
                }
              } catch (e) {
                if (mounted) {
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al pagar multa: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }

  void mostrarComprobante(Map<String, dynamic> pago) async {
    try {
      final comprobanteData = await ApiService().obtenerComprobantePago(
        pago['id'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Comprobante descargado: ${comprobanteData['file'] ?? 'comprobante.pdf'}',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              onPressed: () {
                // Aquí se podría abrir el comprobante
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Comprobante de Pago'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID Pago: ${pago['id']}'),
                        Text('Monto: Bs. ${pago['monto_pagado']}'),
                        Text('Fecha: ${pago['fecha_pago']}'),
                        Text('Referencia: ${pago['referencia'] ?? 'N/A'}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener comprobante: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
