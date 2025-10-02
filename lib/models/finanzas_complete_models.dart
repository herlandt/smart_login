// Modelos de Finanzas basados en el schema OpenAPI real

// ============== FINANZAS ==============
class Gasto {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final String estado;
  final int propiedad;
  final String? descripcion;
  final int? creadoPor;

  Gasto({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.estado,
    required this.propiedad,
    this.descripcion,
    this.creadoPor,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      concepto: json['concepto'],
      monto: double.parse(json['monto'].toString()),
      fechaEmision: DateTime.parse(json['fecha_emision']),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      estado: json['estado'],
      propiedad: json['propiedad'],
      descripcion: json['descripcion'],
      creadoPor: json['creado_por'],
    );
  }
}

class Multa {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final String estado;
  final int propiedad;
  final String? descripcion;
  final String? motivo;
  final int? creadoPor;

  Multa({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.estado,
    required this.propiedad,
    this.descripcion,
    this.motivo,
    this.creadoPor,
  });

  factory Multa.fromJson(Map<String, dynamic> json) {
    return Multa(
      id: json['id'],
      concepto: json['concepto'],
      monto: double.parse(json['monto'].toString()),
      fechaEmision: DateTime.parse(json['fecha_emision']),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      estado: json['estado'],
      propiedad: json['propiedad'],
      descripcion: json['descripcion'],
      motivo: json['motivo'],
      creadoPor: json['creado_por'],
    );
  }
}

class Pago {
  final int id;
  final double monto;
  final DateTime fechaPago;
  final String metodoPago;
  final String? referenciaPago;
  final String estado;
  final int usuario;
  final String? qrData;

  Pago({
    required this.id,
    required this.monto,
    required this.fechaPago,
    required this.metodoPago,
    this.referenciaPago,
    required this.estado,
    required this.usuario,
    this.qrData,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      monto: double.parse(json['monto'].toString()),
      fechaPago: DateTime.parse(json['fecha_pago']),
      metodoPago: json['metodo_pago'],
      referenciaPago: json['referencia_pago'],
      estado: json['estado'],
      usuario: json['usuario'],
      qrData: json['qr_data'],
    );
  }
}

class Reserva {
  final int id;
  final int areaComun;
  final DateTime fechaReserva;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final int usuario;
  final double? costo;
  final String? observaciones;
  final AreaComun? areaComunDetail;

  Reserva({
    required this.id,
    required this.areaComun,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.usuario,
    this.costo,
    this.observaciones,
    this.areaComunDetail,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      areaComun: json['area_comun'],
      fechaReserva: DateTime.parse(json['fecha_reserva']),
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      estado: json['estado'],
      usuario: json['usuario'],
      costo: json['costo']?.toDouble(),
      observaciones: json['observaciones'],
      areaComunDetail: json['area_comun_detail'] != null
          ? AreaComun.fromJson(json['area_comun_detail'])
          : null,
    );
  }
}

// Modelo para estado de cuenta
class EstadoDeCuentaResponse {
  final double totalGastos;
  final double totalMultas;
  final double totalPagado;
  final double saldoPendiente;
  final String tipoDeuda;

  EstadoDeCuentaResponse({
    required this.totalGastos,
    required this.totalMultas,
    required this.totalPagado,
    required this.saldoPendiente,
    required this.tipoDeuda,
  });

  factory EstadoDeCuentaResponse.fromJson(Map<String, dynamic> json) {
    return EstadoDeCuentaResponse(
      totalGastos: double.parse(json['total_gastos'].toString()),
      totalMultas: double.parse(json['total_multas'].toString()),
      totalPagado: double.parse(json['total_pagado'].toString()),
      saldoPendiente: double.parse(json['saldo_pendiente'].toString()),
      tipoDeuda: json['tipo_deuda'],
    );
  }
}

class Egreso {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String categoria;
  final String? descripcion;
  final String? comprobante;

  Egreso({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    required this.categoria,
    this.descripcion,
    this.comprobante,
  });

  factory Egreso.fromJson(Map<String, dynamic> json) {
    return Egreso(
      id: json['id'],
      concepto: json['concepto'],
      monto: double.parse(json['monto'].toString()),
      fecha: DateTime.parse(json['fecha']),
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      comprobante: json['comprobante'],
    );
  }
}

class Ingreso {
  final int id;
  final String concepto;
  final double monto;
  final DateTime fecha;
  final String? descripcion;
  final String? comprobante;

  Ingreso({
    required this.id,
    required this.concepto,
    required this.monto,
    required this.fecha,
    this.descripcion,
    this.comprobante,
  });

  factory Ingreso.fromJson(Map<String, dynamic> json) {
    return Ingreso(
      id: json['id'],
      concepto: json['concepto'],
      monto: double.parse(json['monto'].toString()),
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
      comprobante: json['comprobante'],
    );
  }
}

// Referencia a AreaComun para evitar dependencias circulares
class AreaComun {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? capacidad;
  final double? costoReserva;
  final bool disponible;
  final String? horariosDisponibles;
  final String? reglas;

  AreaComun({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.capacidad,
    this.costoReserva,
    this.disponible = true,
    this.horariosDisponibles,
    this.reglas,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      capacidad: json['capacidad'],
      costoReserva: json['costo_reserva']?.toDouble(),
      disponible: json['disponible'] ?? true,
      horariosDisponibles: json['horarios_disponibles'],
      reglas: json['reglas'],
    );
  }
}
