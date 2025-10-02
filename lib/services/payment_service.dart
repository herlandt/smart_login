import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum MetodoPago {
  tarjetaCredito('Tarjeta de Crédito', 'credit_card'),
  tarjetaDebito('Tarjeta de Débito', 'debit_card'),
  transferenciaBancaria('Transferencia Bancaria', 'bank_transfer'),
  qr('Código QR', 'qr_code'),
  efectivo('Efectivo', 'cash');

  const MetodoPago(this.nombre, this.codigo);
  final String nombre;
  final String codigo;
}

enum EstadoPago {
  pendiente('Pendiente', 'pending'),
  procesando('Procesando', 'processing'),
  exitoso('Exitoso', 'success'),
  fallido('Fallido', 'failed'),
  cancelado('Cancelado', 'cancelled');

  const EstadoPago(this.nombre, this.codigo);
  final String nombre;
  final String codigo;
}

class TransaccionPago {
  final String id;
  final double monto;
  final MetodoPago metodo;
  final EstadoPago estado;
  final DateTime fecha;
  final String? referencia;
  final String? descripcion;
  final Map<String, dynamic>? detallesMetodo;

  TransaccionPago({
    required this.id,
    required this.monto,
    required this.metodo,
    required this.estado,
    required this.fecha,
    this.referencia,
    this.descripcion,
    this.detallesMetodo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'monto': monto,
        'metodo': metodo.codigo,
        'estado': estado.codigo,
        'fecha': fecha.toIso8601String(),
        'referencia': referencia,
        'descripcion': descripcion,
        'detalles_metodo': detallesMetodo,
      };

  factory TransaccionPago.fromJson(Map<String, dynamic> json) => TransaccionPago(
        id: json['id'],
        monto: (json['monto'] as num).toDouble(),
        metodo: MetodoPago.values.firstWhere(
          (m) => m.codigo == json['metodo'],
          orElse: () => MetodoPago.efectivo,
        ),
        estado: EstadoPago.values.firstWhere(
          (e) => e.codigo == json['estado'],
          orElse: () => EstadoPago.pendiente,
        ),
        fecha: DateTime.parse(json['fecha']),
        referencia: json['referencia'],
        descripcion: json['descripcion'],
        detallesMetodo: json['detalles_metodo'],
      );
}

class PaymentService {
  static const String _storageKey = 'transacciones_pago';
  final Random _random = Random();

  // Simular bancos disponibles
  static const List<Map<String, String>> bancosDisponibles = [
    {'codigo': 'BCP', 'nombre': 'Banco de Crédito del Perú'},
    {'codigo': 'BBVA', 'nombre': 'BBVA Continental'},
    {'codigo': 'SCOTIABANK', 'nombre': 'Scotiabank Perú'},
    {'codigo': 'BIF', 'nombre': 'Banco Interamericano de Finanzas'},
    {'codigo': 'PICHINCHA', 'nombre': 'Banco Pichincha'},
  ];

  // Simular procesamiento de pago
  Future<TransaccionPago> procesarPago({
    required double monto,
    required MetodoPago metodo,
    required String descripcion,
    Map<String, dynamic>? detallesMetodo,
  }) async {
    // Simular tiempo de procesamiento
    await Future.delayed(Duration(seconds: 2 + _random.nextInt(3)));

    final transaccionId = _generarIdTransaccion();
    final referencia = _generarReferencia();

    // Simular diferentes resultados (85% exitoso, 10% fallido, 5% procesando)
    final estadoAleatorio = _random.nextDouble();
    EstadoPago estado;
    
    if (estadoAleatorio < 0.85) {
      estado = EstadoPago.exitoso;
    } else if (estadoAleatorio < 0.95) {
      estado = EstadoPago.fallido;
    } else {
      estado = EstadoPago.procesando;
    }

    final transaccion = TransaccionPago(
      id: transaccionId,
      monto: monto,
      metodo: metodo,
      estado: estado,
      fecha: DateTime.now(),
      referencia: referencia,
      descripcion: descripcion,
      detallesMetodo: detallesMetodo,
    );

    // Guardar la transacción localmente
    await _guardarTransaccion(transaccion);

    return transaccion;
  }

  // Simular validación de tarjeta
  Future<bool> validarTarjeta({
    required String numero,
    required String vencimiento,
    required String cvv,
    required String titular,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Validaciones básicas
    if (numero.length < 13 || numero.length > 19) return false;
    if (vencimiento.length != 5) return false;
    if (cvv.length < 3 || cvv.length > 4) return false;
    if (titular.trim().isEmpty) return false;

    // Simular 90% de éxito
    return _random.nextDouble() < 0.9;
  }

  // Simular consulta de saldo
  Future<double> consultarSaldo(String numeroCuenta) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simular saldo aleatorio entre 100 y 10000
    return 100 + _random.nextDouble() * 9900;
  }

  // Obtener historial de transacciones
  Future<List<TransaccionPago>> obtenerHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey) ?? '[]';
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    return jsonList
        .map((json) => TransaccionPago.fromJson(json))
        .toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  // Generar código QR para pago
  Map<String, String> generarCodigoQR(double monto, String concepto) {
    final qrId = _generarIdTransaccion();
    final qrData = 'SMART_CONDOMINIO|$monto|$concepto|$qrId';
    
    return {
      'qr_id': qrId,
      'qr_data': qrData,
      'url_qr': 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(qrData)}',
    };
  }

  // Verificar estado de pago QR
  Future<EstadoPago> verificarPagoQR(String qrId) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simular diferentes estados
    final random = _random.nextDouble();
    if (random < 0.3) return EstadoPago.exitoso;
    if (random < 0.4) return EstadoPago.fallido;
    return EstadoPago.pendiente;
  }

  // Métodos privados de utilidad
  String _generarIdTransaccion() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final aleatorio = _random.nextInt(9999).toString().padLeft(4, '0');
    return 'TXN$timestamp$aleatorio';
  }

  String _generarReferencia() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(12, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }

  Future<void> _guardarTransaccion(TransaccionPago transaccion) async {
    final prefs = await SharedPreferences.getInstance();
    final historial = await obtenerHistorial();
    historial.insert(0, transaccion);
    
    // Mantener solo las últimas 100 transacciones
    if (historial.length > 100) {
      historial.removeRange(100, historial.length);
    }
    
    final jsonString = jsonEncode(historial.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // Simular reembolso
  Future<TransaccionPago> procesarReembolso(String transaccionOriginalId, double monto) async {
    await Future.delayed(const Duration(seconds: 2));

    final transaccion = TransaccionPago(
      id: _generarIdTransaccion(),
      monto: -monto, // Monto negativo para reembolso
      metodo: MetodoPago.transferenciaBancaria,
      estado: EstadoPago.exitoso,
      fecha: DateTime.now(),
      referencia: _generarReferencia(),
      descripcion: 'Reembolso de transacción $transaccionOriginalId',
    );

    await _guardarTransaccion(transaccion);
    return transaccion;
  }

  // Calcular comisión por método de pago
  double calcularComision(MetodoPago metodo, double monto) {
    switch (metodo) {
      case MetodoPago.tarjetaCredito:
        return monto * 0.035; // 3.5%
      case MetodoPago.tarjetaDebito:
        return monto * 0.02; // 2%
      case MetodoPago.transferenciaBancaria:
        return 5.0; // Monto fijo
      case MetodoPago.qr:
        return monto * 0.01; // 1%
      case MetodoPago.efectivo:
        return 0.0; // Sin comisión
    }
  }
}