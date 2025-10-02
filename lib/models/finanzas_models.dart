// Modelos de finanzas basados en la documentación REAL del backend

class AreaComun {
  final int id;
  final String nombre;
  final String? descripcion;
  final int capacidad;
  final String costoReserva; // Decimal como string
  final bool disponible;
  final String? horarioApertura; // HH:mm:ss
  final String? horarioCierre; // HH:mm:ss
  final String? reglas;

  AreaComun({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.capacidad,
    required this.costoReserva,
    required this.disponible,
    this.horarioApertura,
    this.horarioCierre,
    this.reglas,
  });

  factory AreaComun.fromJson(Map<String, dynamic> json) {
    return AreaComun(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      capacidad: json['capacidad'],
      costoReserva: json['costo_reserva'],
      disponible: json['disponible'],
      horarioApertura: json['horario_apertura'],
      horarioCierre: json['horario_cierre'],
      reglas: json['reglas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'capacidad': capacidad,
      'costo_reserva': costoReserva,
      'disponible': disponible,
      'horario_apertura': horarioApertura,
      'horario_cierre': horarioCierre,
      'reglas': reglas,
    };
  }
}

class Gasto {
  final int id;
  final String monto; // Decimal como string
  final String fechaEmision; // YYYY-MM-DD
  final String? fechaVencimiento;
  final String descripcion;
  final String categoria; // EXPENSA, MANTENIMIENTO, etc.
  final bool pagado;
  final int mes;
  final int anio;
  final int propiedad;

  Gasto({
    required this.id,
    required this.monto,
    required this.fechaEmision,
    this.fechaVencimiento,
    required this.descripcion,
    required this.categoria,
    required this.pagado,
    required this.mes,
    required this.anio,
    required this.propiedad,
  });

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      monto: json['monto'],
      fechaEmision: json['fecha_emision'],
      fechaVencimiento: json['fecha_vencimiento'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      pagado: json['pagado'],
      mes: json['mes'],
      anio: json['anio'],
      propiedad: json['propiedad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'fecha_emision': fechaEmision,
      'fecha_vencimiento': fechaVencimiento,
      'descripcion': descripcion,
      'categoria': categoria,
      'pagado': pagado,
      'mes': mes,
      'anio': anio,
      'propiedad': propiedad,
    };
  }
}

class Reserva {
  final int id;
  final int areaComun;
  final int usuario;
  final String fechaReserva; // YYYY-MM-DD
  final String horaInicio; // HH:mm:ss
  final String horaFin; // HH:mm:ss
  final String estado; // SOLICITADA, CONFIRMADA, PAGADA, CANCELADA
  final String? costo;
  final String? observaciones;
  final AreaComun? areaComunDetail;

  Reserva({
    required this.id,
    required this.areaComun,
    required this.usuario,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    this.costo,
    this.observaciones,
    this.areaComunDetail,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      areaComun: json['area_comun'],
      usuario: json['usuario'],
      fechaReserva: json['fecha_reserva'],
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      estado: json['estado'],
      costo: json['costo'],
      observaciones: json['observaciones'],
      areaComunDetail: json['area_comun_detail'] != null
          ? AreaComun.fromJson(json['area_comun_detail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_comun': areaComun,
      'usuario': usuario,
      'fecha_reserva': fechaReserva,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'costo': costo,
      'observaciones': observaciones,
      if (areaComunDetail != null)
        'area_comun_detail': areaComunDetail!.toJson(),
    };
  }
}

class Pago {
  final int id;
  final int usuario;
  final String montoTotal;
  final String fechaPago; // ISO datetime
  final String estadoPago; // PENDIENTE, PAGADO, FALLIDO, CANCELADO
  final String metodoPago; // STRIPE, PAGOSNET, EFECTIVO, TRANSFERENCIA
  final String? idTransaccionPasarela;
  final String? comprobante;
  final String? qrData;

  Pago({
    required this.id,
    required this.usuario,
    required this.montoTotal,
    required this.fechaPago,
    required this.estadoPago,
    required this.metodoPago,
    this.idTransaccionPasarela,
    this.comprobante,
    this.qrData,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      usuario: json['usuario'],
      montoTotal: json['monto_total'],
      fechaPago: json['fecha_pago'],
      estadoPago: json['estado_pago'],
      metodoPago: json['metodo_pago'],
      idTransaccionPasarela: json['id_transaccion_pasarela'],
      comprobante: json['comprobante'],
      qrData: json['qr_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'monto_total': montoTotal,
      'fecha_pago': fechaPago,
      'estado_pago': estadoPago,
      'metodo_pago': metodoPago,
      'id_transaccion_pasarela': idTransaccionPasarela,
      'comprobante': comprobante,
      'qr_data': qrData,
    };
  }
}
