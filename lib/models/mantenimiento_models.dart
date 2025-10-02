// Modelos de mantenimiento basados en la documentación del backend

class PersonalMantenimiento {
  final int? id;
  final String nombre;
  final String telefono;
  final String especialidad; // ELECTRICIDAD/PLOMERIA/JARDINERIA/etc.
  final bool activo;

  PersonalMantenimiento({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.especialidad,
    this.activo = true,
  });

  factory PersonalMantenimiento.fromJson(Map<String, dynamic> json) {
    return PersonalMantenimiento(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      especialidad: json['especialidad'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'especialidad': especialidad,
      'activo': activo,
    };
  }
}

class SolicitudMantenimiento {
  final int? id;
  final String titulo;
  final String descripcion;
  final int propiedadId;
  final String estado; // PENDIENTE/EN_PROGRESO/COMPLETADA/CERRADA
  final String prioridad; // BAJA/MEDIA/ALTA/URGENTE
  final int? asignadoA;
  final DateTime? fechaCreacion;
  final DateTime? fechaResolucion;

  SolicitudMantenimiento({
    this.id,
    required this.titulo,
    required this.descripcion,
    required this.propiedadId,
    this.estado = 'PENDIENTE',
    this.prioridad = 'MEDIA',
    this.asignadoA,
    this.fechaCreacion,
    this.fechaResolucion,
  });

  factory SolicitudMantenimiento.fromJson(Map<String, dynamic> json) {
    return SolicitudMantenimiento(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      propiedadId: json['propiedad'],
      estado: json['estado'] ?? 'PENDIENTE',
      prioridad: json['prioridad'] ?? 'MEDIA',
      asignadoA: json['asignado_a'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
      fechaResolucion: json['fecha_resolucion'] != null
          ? DateTime.parse(json['fecha_resolucion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'propiedad': propiedadId,
      'estado': estado,
      'prioridad': prioridad,
      if (asignadoA != null) 'asignado_a': asignadoA,
      if (fechaCreacion != null)
        'fecha_creacion': fechaCreacion!.toIso8601String(),
      if (fechaResolucion != null)
        'fecha_resolucion': fechaResolucion!.toIso8601String(),
    };
  }

  // Métodos de utilidad
  String get estadoFormatted {
    switch (estado) {
      case 'PENDIENTE':
        return '🔵 Pendiente';
      case 'EN_PROGRESO':
        return '🟡 En Progreso';
      case 'COMPLETADA':
        return '🟢 Completada';
      case 'CERRADA':
        return '⚫ Cerrada';
      default:
        return estado;
    }
  }

  String get prioridadFormatted {
    switch (prioridad) {
      case 'BAJA':
        return '🟢 Baja';
      case 'MEDIA':
        return '🟡 Media';
      case 'ALTA':
        return '🟠 Alta';
      case 'URGENTE':
        return '🔴 Urgente';
      default:
        return prioridad;
    }
  }
}

// Modelo para cambiar estado de solicitud
class CambiarEstadoRequest {
  final String estado;

  CambiarEstadoRequest({required this.estado});

  Map<String, dynamic> toJson() {
    return {'estado': estado};
  }
}

// Modelo para asignar técnico
class AsignarTecnicoRequest {
  final int personalId;

  AsignarTecnicoRequest({required this.personalId});

  Map<String, dynamic> toJson() {
    return {'personal_id': personalId};
  }
}
