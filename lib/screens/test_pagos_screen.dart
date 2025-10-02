import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/payment_service.dart';
import 'pasarela_pago_screen.dart';

class TestPagosScreen extends StatefulWidget {
  const TestPagosScreen({super.key});

  @override
  State<TestPagosScreen> createState() => _TestPagosScreenState();
}

class _TestPagosScreenState extends State<TestPagosScreen> {
  List<dynamic>? gastosTest;
  List<dynamic>? multasTest;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarDatosTest();
  }

  Future<void> cargarDatosTest() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final api = ApiService();
      final futures = await Future.wait([
        api.fetchGastos().catchError((e) => <dynamic>[]),
        api.fetchMultas().catchError((e) => <dynamic>[]),
      ]);

      setState(() {
        gastosTest = futures[0];
        multasTest = futures[1];
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
        title: const Text('🧪 Test de Pagos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarDatosTest,
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
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: cargarDatosTest,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del test
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Estado del Test de Pagos',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Gastos cargados: ${gastosTest?.length ?? 0}'),
                          Text('Multas cargadas: ${multasTest?.length ?? 0}'),
                          const SizedBox(height: 8),
                          Text(
                            'Los pagos son simulados y no afectan datos reales.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones de test rápido
                  Text(
                    'Tests Rápidos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _testPagoRapido(100.0),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Pago Bs. 100'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _testPagoRapido(250.0),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Pago Bs. 250'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _testPagoRapido(500.0),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('Pago Bs. 500'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _testTodasLasFormasPago,
                        icon: const Icon(Icons.credit_card),
                        label: const Text('Test Métodos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Gastos pendientes
                  if (gastosTest != null && gastosTest!.isNotEmpty) ...[
                    Text(
                      'Gastos Pendientes para Test',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...gastosTest!
                        .take(3)
                        .map(
                          (gasto) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.receipt,
                                color: Colors.orange,
                              ),
                              title: Text('Bs. ${gasto['monto'] ?? '0'}'),
                              subtitle: Text(
                                gasto['descripcion'] ?? 'Sin descripción',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _testPagoGasto(gasto),
                                child: const Text('Test Pago'),
                              ),
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 20),

                  // Multas pendientes
                  if (multasTest != null && multasTest!.isNotEmpty) ...[
                    Text(
                      'Multas Pendientes para Test',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...multasTest!
                        .take(3)
                        .map(
                          (multa) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                              title: Text('Bs. ${multa['monto'] ?? '0'}'),
                              subtitle: Text(
                                multa['concepto'] ?? 'Sin concepto',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _testPagoMulta(multa),
                                child: const Text('Test Pago'),
                              ),
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 20),

                  // Test de endpoints
                  Card(
                    color: Colors.yellow.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test de Endpoints',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _testEndpointsPago,
                            icon: const Icon(Icons.api),
                            label: const Text('Probar Endpoints de Pago'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _testPagoRapido(double monto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasarelaPagoScreen(
          monto: monto,
          concepto: 'Test de pago rápido',
          descripcion: 'Pago de prueba por Bs. $monto',
          onPagoCompletado: (transaccion) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Test completado: ${transaccion.estado.nombre} - ID: ${transaccion.id}',
                ),
                backgroundColor: transaccion.estado == EstadoPago.exitoso
                    ? Colors.green
                    : Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }

  void _testPagoGasto(Map<String, dynamic> gasto) {
    final monto = double.tryParse(gasto['monto'].toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasarelaPagoScreen(
          monto: monto,
          concepto: 'Test - Pago de gasto',
          descripcion: gasto['descripcion'] ?? 'Gasto sin descripción',
          onPagoCompletado: (transaccion) async {
            try {
              if (transaccion.estado == EstadoPago.exitoso) {
                await ApiService().pagarGasto(
                  gasto['id'],
                  montoPagado: transaccion.monto,
                  metodoPago: transaccion.metodo.codigo,
                  referencia: transaccion.referencia,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test de gasto completado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error en test de gasto: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _testPagoMulta(Map<String, dynamic> multa) {
    final monto = double.tryParse(multa['monto'].toString()) ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasarelaPagoScreen(
          monto: monto,
          concepto: 'Test - Pago de multa',
          descripcion: multa['concepto'] ?? 'Multa sin concepto',
          onPagoCompletado: (transaccion) async {
            try {
              if (transaccion.estado == EstadoPago.exitoso) {
                await ApiService().pagarMulta(
                  multa['id'],
                  montoPagado: transaccion.monto,
                  metodoPago: transaccion.metodo.codigo,
                  referencia: transaccion.referencia,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test de multa completado exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error en test de multa: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _testTodasLasFormasPago() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test de Métodos de Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Tarjeta de Crédito'),
              onTap: () {
                Navigator.pop(context);
                _testMetodoPago(MetodoPago.tarjetaCredito);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Transferencia Bancaria'),
              onTap: () {
                Navigator.pop(context);
                _testMetodoPago(MetodoPago.transferenciaBancaria);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Código QR'),
              onTap: () {
                Navigator.pop(context);
                _testMetodoPago(MetodoPago.qr);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _testMetodoPago(MetodoPago metodo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testeando método: ${metodo.nombre}'),
        duration: const Duration(seconds: 1),
      ),
    );
    _testPagoRapido(150.0);
  }

  Future<void> _testEndpointsPago() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Probando endpoints de pago...'),
          ],
        ),
      ),
    );

    final List<String> resultados = [];

    try {
      // Test 1: Obtener gastos
      try {
        final gastos = await ApiService().fetchGastos();
        resultados.add('✅ Gastos: ${gastos.length} elementos');
      } catch (e) {
        resultados.add('❌ Gastos: $e');
      }

      // Test 2: Obtener pagos
      try {
        final pagos = await ApiService().fetchPagos();
        resultados.add('✅ Pagos: ${pagos.length} elementos');
      } catch (e) {
        resultados.add('❌ Pagos: $e');
      }

      // Test 3: Obtener multas
      try {
        final multas = await ApiService().fetchMultas();
        resultados.add('✅ Multas: ${multas.length} elementos');
      } catch (e) {
        resultados.add('❌ Multas: $e');
      }

      // Test 4: Simular pago (solo si hay datos)
      if (gastosTest != null && gastosTest!.isNotEmpty) {
        try {
          final primerGasto = gastosTest!.first;
          if (primerGasto['id'] != null) {
            await ApiService().simularPago(primerGasto['id']);
            resultados.add('✅ Simulación de pago: OK');
          }
        } catch (e) {
          resultados.add('❌ Simulación de pago: $e');
        }
      }
    } catch (e) {
      resultados.add('❌ Error general: $e');
    }

    Navigator.pop(context); // Cerrar loading dialog

    // Mostrar resultados
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultados del Test'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: resultados.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                resultados[index],
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: resultados[index].startsWith('✅')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
