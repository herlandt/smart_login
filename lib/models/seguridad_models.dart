// Modelos de seguridad basados en la documentación del backend

class Visitante {
  final int? id;
  final String nombreCompleto;
  final String documento;
  final String telefono;
  final String? email;

  Visitante({
    this.id,
    required this.nombreCompleto,
    required this.documento,
    required this.telefono,
    this.email,
  });

  factory Visitante.fromJson(Map<String, dynamic> json) {
    return Visitante(
      id: json['id'],
      nombreCompleto: json['nombre_completo'],
      documento: json['documento'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'documento': documento,
      'telefono': telefono,
      if (email != null) 'email': email,
    };
  }
}

class Vehiculo {
  final int? id;
  final String placa;
  final String modelo;
  final String color;
  final int? propiedadId;
  final int? visitanteId;
  final String tipo; // residente/visitante

  Vehiculo({
    this.id,
    required this.placa,
    required this.modelo,
    required this.color,
    this.propiedadId,
    this.visitanteId,
    required this.tipo,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      placa: json['placa'],
      modelo: json['modelo'],
      color: json['color'],
      propiedadId: json['propiedad'],
      visitanteId: json['visitante'],
      tipo: json['tipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'modelo': modelo,
      'color': color,
      if (propiedadId != null) 'propiedad': propiedadId,
      if (visitanteId != null) 'visitante': visitanteId,
      'tipo': tipo,
    };
  }
}

class Visita {
  final int? id;
  final int visitanteId;
  final int propiedadId;
  final DateTime? fechaProgramadaInicio;
  final DateTime? fechaProgramadaFin;
  final DateTime? ingresoReal;
  final DateTime? salidaReal;
  final String estado; // PROGRAMADA/EN_CURSO/FINALIZADA/CANCELADA

  Visita({
    this.id,
    required this.visitanteId,
    required this.propiedadId,
    this.fechaProgramadaInicio,
    this.fechaProgramadaFin,
    this.ingresoReal,
    this.salidaReal,
    this.estado = 'PROGRAMADA',
  });

  factory Visita.fromJson(Map<String, dynamic> json) {
    return Visita(
      id: json['id'],
      visitanteId: json['visitante'],
      propiedadId: json['propiedad'],
      fechaProgramadaInicio: json['fecha_programada_inicio'] != null
          ? DateTime.parse(json['fecha_programada_inicio'])
          : null,
      fechaProgramadaFin: json['fecha_programada_fin'] != null
          ? DateTime.parse(json['fecha_programada_fin'])
          : null,
      ingresoReal: json['ingreso_real'] != null
          ? DateTime.parse(json['ingreso_real'])
          : null,
      salidaReal: json['salida_real'] != null
          ? DateTime.parse(json['salida_real'])
          : null,
      estado: json['estado'] ?? 'PROGRAMADA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitante': visitanteId,
      'propiedad': propiedadId,
      if (fechaProgramadaInicio != null)
        'fecha_programada_inicio': fechaProgramadaInicio!.toIso8601String(),
      if (fechaProgramadaFin != null)
        'fecha_programada_fin': fechaProgramadaFin!.toIso8601String(),
      if (ingresoReal != null) 'ingreso_real': ingresoReal!.toIso8601String(),
      if (salidaReal != null) 'salida_real': salidaReal!.toIso8601String(),
      'estado': estado,
    };
  }

  // Métodos de utilidad
  String get estadoFormatted {
    switch (estado) {
      case 'PROGRAMADA':
        return '🔵 Programada';
      case 'EN_CURSO':
        return '🟡 En Curso';
      case 'FINALIZADA':
        return '🟢 Finalizada';
      case 'CANCELADA':
        return '🔴 Cancelada';
      default:
        return estado;
    }
  }

  bool get isActive => estado == 'EN_CURSO';
  bool get isScheduled => estado == 'PROGRAMADA';
  bool get isFinished => estado == 'FINALIZADA';
  bool get isCancelled => estado == 'CANCELADA';
}

class EventoSeguridad {
  final int? id;
  final String tipo;
  final String descripcion;
  final DateTime fechaHora;
  final String ubicacion;
  final String gravedad;
  final bool resuelto;

  EventoSeguridad({
    this.id,
    required this.tipo,
    required this.descripcion,
    required this.fechaHora,
    required this.ubicacion,
    required this.gravedad,
    this.resuelto = false,
  });

  factory EventoSeguridad.fromJson(Map<String, dynamic> json) {
    return EventoSeguridad(
      id: json['id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      ubicacion: json['ubicacion'],
      gravedad: json['gravedad'],
      resuelto: json['resuelto'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'descripcion': descripcion,
      'fecha_hora': fechaHora.toIso8601String(),
      'ubicacion': ubicacion,
      'gravedad': gravedad,
      'resuelto': resuelto,
    };
  }
}

// Modelo para control de acceso vehicular
class ControlAccesoVehicular {
  final String placa;

  ControlAccesoVehicular({required this.placa});

  Map<String, dynamic> toJson() {
    return {'placa': placa};
  }
}

// Respuesta del control de acceso
class ControlAccesoResponse {
  final String detail;
  final String tipo;
  final bool accesoConcedido;

  ControlAccesoResponse({
    required this.detail,
    required this.tipo,
    required this.accesoConcedido,
  });

  factory ControlAccesoResponse.fromJson(Map<String, dynamic> json) {
    return ControlAccesoResponse(
      detail: json['detail'],
      tipo: json['tipo'],
      accesoConcedido: json['detail'].toString().toLowerCase().contains(
        'permitido',
      ),
    );
  }
}
