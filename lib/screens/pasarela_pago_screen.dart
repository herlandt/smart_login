import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service.dart';

class PasarelaPagoScreen extends StatefulWidget {
  final double monto;
  final String concepto;
  final String? descripcion;
  final Function(TransaccionPago) onPagoCompletado;
  final VoidCallback? onCancelado;

  const PasarelaPagoScreen({
    super.key,
    required this.monto,
    required this.concepto,
    required this.onPagoCompletado,
    this.descripcion,
    this.onCancelado,
  });

  @override
  State<PasarelaPagoScreen> createState() => _PasarelaPagoScreenState();
}

class _PasarelaPagoScreenState extends State<PasarelaPagoScreen> {
  final PaymentService _paymentService = PaymentService();
  MetodoPago _metodoSeleccionado = MetodoPago.tarjetaCredito;
  bool _procesandoPago = false;

  // Controladores para tarjeta
  final _numeroTarjetaController = TextEditingController();
  final _vencimientoController = TextEditingController();
  final _cvvController = TextEditingController();
  final _titularController = TextEditingController();

  // Controladores para transferencia
  String? _bancoSeleccionado;
  final _numeroCuentaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final comision = _paymentService.calcularComision(_metodoSeleccionado, widget.monto);
    final montoTotal = widget.monto + comision;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasarela de Pago'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancelado ?? () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen del pago
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Pago',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Concepto:', style: Theme.of(context).textTheme.bodyMedium),
                        Expanded(
                          child: Text(
                            widget.concepto,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    if (widget.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Descripción:', style: Theme.of(context).textTheme.bodySmall),
                          Expanded(
                            child: Text(
                              widget.descripcion!,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:', style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          'Bs. ${widget.monto.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Comisión:', style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          'Bs. ${comision.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bs. ${montoTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selección de método de pago
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método de Pago',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...MetodoPago.values.map((metodo) => RadioListTile<MetodoPago>(
                      title: Row(
                        children: [
                          _getIconoMetodo(metodo),
                          const SizedBox(width: 8),
                          Text(metodo.nombre),
                        ],
                      ),
                      subtitle: Text(_getDescripcionMetodo(metodo)),
                      value: metodo,
                      groupValue: _metodoSeleccionado,
                      onChanged: (valor) {
                        setState(() {
                          _metodoSeleccionado = valor!;
                        });
                      },
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Formulario específico del método
            _buildFormularioMetodo(),

            const SizedBox(height: 20),

            // Botón de pago
            ElevatedButton(
              onPressed: _procesandoPago ? null : _procesarPago,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _procesandoPago
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Procesando...'),
                      ],
                    )
                  : Text(
                      'Pagar Bs. ${montoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioMetodo() {
    switch (_metodoSeleccionado) {
      case MetodoPago.tarjetaCredito:
      case MetodoPago.tarjetaDebito:
        return _buildFormularioTarjeta();
      case MetodoPago.transferenciaBancaria:
        return _buildFormularioTransferencia();
      case MetodoPago.qr:
        return _buildFormularioQR();
      case MetodoPago.efectivo:
        return _buildFormularioEfectivo();
    }
  }

  Widget _buildFormularioTarjeta() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datos de la Tarjeta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numeroTarjetaController,
              decoration: const InputDecoration(
                labelText: 'Número de Tarjeta',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
                _CardNumberInputFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vencimientoController,
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      hintText: '12/28',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateInputFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titularController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Titular',
                hintText: 'Juan Pérez',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioTransferencia() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transferencia Bancaria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Banco',
                prefixIcon: Icon(Icons.account_balance),
              ),
              value: _bancoSeleccionado,
              items: PaymentService.bancosDisponibles.map((banco) {
                return DropdownMenuItem(
                  value: banco['codigo'],
                  child: Text(banco['nombre']!),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _bancoSeleccionado = valor;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numeroCuentaController,
              decoration: const InputDecoration(
                labelText: 'Número de Cuenta',
                hintText: '1234567890',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioQR() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.qr_code,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Pago con Código QR',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se generará un código QR que podrás escanear con tu app bancaria favorita.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioEfectivo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.money,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Pago en Efectivo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podrás realizar el pago en efectivo en la administración del condominio.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Icon _getIconoMetodo(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.tarjetaCredito:
        return const Icon(Icons.credit_card, color: Colors.blue);
      case MetodoPago.tarjetaDebito:
        return const Icon(Icons.credit_card, color: Colors.green);
      case MetodoPago.transferenciaBancaria:
        return const Icon(Icons.account_balance, color: Colors.orange);
      case MetodoPago.qr:
        return const Icon(Icons.qr_code, color: Colors.purple);
      case MetodoPago.efectivo:
        return const Icon(Icons.money, color: Colors.brown);
    }
  }

  String _getDescripcionMetodo(MetodoPago metodo) {
    final comision = _paymentService.calcularComision(metodo, widget.monto);
    switch (metodo) {
      case MetodoPago.tarjetaCredito:
        return 'Comisión: 3.5% (Bs. ${comision.toStringAsFixed(2)})';
      case MetodoPago.tarjetaDebito:
        return 'Comisión: 2% (Bs. ${comision.toStringAsFixed(2)})';
      case MetodoPago.transferenciaBancaria:
        return 'Comisión: Bs. ${comision.toStringAsFixed(2)}';
      case MetodoPago.qr:
        return 'Comisión: 1% (Bs. ${comision.toStringAsFixed(2)})';
      case MetodoPago.efectivo:
        return 'Sin comisión';
    }
  }

  Future<void> _procesarPago() async {
    if (!_validarFormulario()) return;

    setState(() {
      _procesandoPago = true;
    });

    try {
      Map<String, dynamic>? detallesMetodo;

      // Preparar detalles específicos del método
      if (_metodoSeleccionado == MetodoPago.tarjetaCredito ||
          _metodoSeleccionado == MetodoPago.tarjetaDebito) {
        // Validar tarjeta primero
        final esValida = await _paymentService.validarTarjeta(
          numero: _numeroTarjetaController.text.replaceAll(' ', ''),
          vencimiento: _vencimientoController.text,
          cvv: _cvvController.text,
          titular: _titularController.text,
        );

        if (!esValida) {
          throw Exception('Datos de tarjeta inválidos');
        }

        detallesMetodo = {
          'numero_tarjeta': '**** **** **** ${_numeroTarjetaController.text.substring(_numeroTarjetaController.text.length - 4)}',
          'titular': _titularController.text,
          'vencimiento': _vencimientoController.text,
        };
      } else if (_metodoSeleccionado == MetodoPago.transferenciaBancaria) {
        detallesMetodo = {
          'banco': _bancoSeleccionado,
          'numero_cuenta': _numeroCuentaController.text,
        };
      } else if (_metodoSeleccionado == MetodoPago.qr) {
        final qrData = _paymentService.generarCodigoQR(widget.monto, widget.concepto);
        detallesMetodo = qrData;
      }

      final comision = _paymentService.calcularComision(_metodoSeleccionado, widget.monto);
      final montoTotal = widget.monto + comision;

      final transaccion = await _paymentService.procesarPago(
        monto: montoTotal,
        metodo: _metodoSeleccionado,
        descripcion: widget.descripcion ?? widget.concepto,
        detallesMetodo: detallesMetodo,
      );

      if (mounted) {
        widget.onPagoCompletado(transaccion);
        Navigator.pop(context);
        
        // Mostrar resultado
        _mostrarResultadoPago(transaccion);
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
    } finally {
      if (mounted) {
        setState(() {
          _procesandoPago = false;
        });
      }
    }
  }

  bool _validarFormulario() {
    switch (_metodoSeleccionado) {
      case MetodoPago.tarjetaCredito:
      case MetodoPago.tarjetaDebito:
        if (_numeroTarjetaController.text.replaceAll(' ', '').length < 13 ||
            _vencimientoController.text.length != 5 ||
            _cvvController.text.length < 3 ||
            _titularController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor completa todos los datos de la tarjeta'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      case MetodoPago.transferenciaBancaria:
        if (_bancoSeleccionado == null || _numeroCuentaController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor selecciona el banco y número de cuenta'),
              backgroundColor: Colors.orange,
            ),
          );
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }

  void _mostrarResultadoPago(TransaccionPago transaccion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              transaccion.estado == EstadoPago.exitoso
                  ? Icons.check_circle
                  : transaccion.estado == EstadoPago.fallido
                      ? Icons.error
                      : Icons.schedule,
              color: transaccion.estado == EstadoPago.exitoso
                  ? Colors.green
                  : transaccion.estado == EstadoPago.fallido
                      ? Colors.red
                      : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(transaccion.estado.nombre),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transacción: ${transaccion.id}'),
            Text('Monto: Bs. ${transaccion.monto.toStringAsFixed(2)}'),
            Text('Método: ${transaccion.metodo.nombre}'),
            if (transaccion.referencia != null)
              Text('Referencia: ${transaccion.referencia}'),
            Text('Fecha: ${transaccion.fecha.toString().substring(0, 19)}'),
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

  @override
  void dispose() {
    _numeroTarjetaController.dispose();
    _vencimientoController.dispose();
    _cvvController.dispose();
    _titularController.dispose();
    _numeroCuentaController.dispose();
    super.dispose();
  }
}

// Formateadores de texto personalizados
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}