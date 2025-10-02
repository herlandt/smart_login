import 'package:flutter/material.dart';
import 'dart:async';
import '../services/payment_service.dart';

class PagoQRScreen extends StatefulWidget {
  final double monto;
  final String concepto;
  final Function(TransaccionPago) onPagoCompletado;

  const PagoQRScreen({
    super.key,
    required this.monto,
    required this.concepto,
    required this.onPagoCompletado,
  });

  @override
  State<PagoQRScreen> createState() => _PagoQRScreenState();
}

class _PagoQRScreenState extends State<PagoQRScreen> {
  final PaymentService _paymentService = PaymentService();
  late Map<String, String> _qrData;
  Timer? _verificacionTimer;
  bool _verificandoPago = false;
  int _segundosRestantes = 300; // 5 minutos

  @override
  void initState() {
    super.initState();
    _generarQR();
    _iniciarVerificacion();
    _iniciarContadorTiempo();
  }

  void _generarQR() {
    _qrData = _paymentService.generarCodigoQR(widget.monto, widget.concepto);
  }

  void _iniciarVerificacion() {
    _verificacionTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _verificandoPago = true;
      });

      try {
        final estado = await _paymentService.verificarPagoQR(_qrData['qr_id']!);
        
        if (estado == EstadoPago.exitoso) {
          timer.cancel();
          await _procesarPagoExitoso();
        } else if (estado == EstadoPago.fallido) {
          timer.cancel();
          _mostrarErrorPago();
        }
      } catch (e) {
        // Error en verificación, continuar intentando
      } finally {
        if (mounted) {
          setState(() {
            _verificandoPago = false;
          });
        }
      }
    });
  }

  void _iniciarContadorTiempo() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _segundosRestantes <= 0) {
        timer.cancel();
        if (mounted && _segundosRestantes <= 0) {
          _mostrarTiempoAgotado();
        }
        return;
      }

      setState(() {
        _segundosRestantes--;
      });
    });
  }

  Future<void> _procesarPagoExitoso() async {
    try {
      final transaccion = await _paymentService.procesarPago(
        monto: widget.monto,
        metodo: MetodoPago.qr,
        descripcion: widget.concepto,
        detallesMetodo: _qrData,
      );

      if (mounted) {
        widget.onPagoCompletado(transaccion);
        Navigator.pop(context);
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Pago Exitoso'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monto: Bs. ${widget.monto.toStringAsFixed(2)}'),
                Text('Concepto: ${widget.concepto}'),
                Text('Transacción: ${transaccion.id}'),
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

  void _mostrarErrorPago() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error en el Pago'),
          ],
        ),
        content: const Text(
          'Hubo un error al procesar el pago. Por favor, intenta nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _segundosRestantes = 300;
                _generarQR();
              });
              _iniciarVerificacion();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _mostrarTiempoAgotado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange),
            SizedBox(width: 8),
            Text('Tiempo Agotado'),
          ],
        ),
        content: const Text(
          'El tiempo para realizar el pago ha expirado. Puedes generar un nuevo código QR.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _segundosRestantes = 300;
                _generarQR();
              });
              _iniciarVerificacion();
            },
            child: const Text('Nuevo QR'),
          ),
        ],
      ),
    );
  }

  String _formatearTiempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con QR'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Información del pago
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Bs. ${widget.monto.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.concepto,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Código QR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _qrData['url_qr']!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code, size: 64),
                                  Text('Código QR'),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ID: ${_qrData['qr_id']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tiempo restante y estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: _segundosRestantes < 60 ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tiempo restante: ${_formatearTiempo(_segundosRestantes)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _segundosRestantes < 60 ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_verificandoPago)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Verificando pago...'),
                        ],
                      )
                    else
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Esperando pago...'),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instrucciones
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instrucciones:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Abre tu app bancaria o de pagos favorita'),
                    const SizedBox(height: 4),
                    const Text('2. Escanea el código QR mostrado arriba'),
                    const SizedBox(height: 4),
                    const Text('3. Verifica el monto y confirma el pago'),
                    const SizedBox(height: 4),
                    const Text('4. El pago se procesará automáticamente'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _segundosRestantes = 300;
                        _generarQR();
                      });
                      _iniciarVerificacion();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Nuevo QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verificacionTimer?.cancel();
    super.dispose();
  }
}