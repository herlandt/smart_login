// Modelos de Seguridad y Mantenimiento basados en el schema OpenAPI real

// ============== SEGURIDAD ==============
class RegistroAcceso {
  final int id;
  final int usuario;
  final DateTime fechaHora;
  final String tipoAcceso; // entrada, salida
  final String metodoAcceso; // QR, tarjeta, manual
  final String ubicacion;
  final String? observaciones;
  final bool? permitido;

  RegistroAcceso({
    required this.id,
    required this.usuario,
    required this.fechaHora,
    required this.tipoAcceso,
    required this.metodoAcceso,
    required this.ubicacion,
    this.observaciones,
    this.permitido,
  });

  factory RegistroAcceso.fromJson(Map<String, dynamic> json) {
    return RegistroAcceso(
      id: json['id'],
      usuario: json['usuario'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      tipoAcceso: json['tipo_acceso'],
      metodoAcceso: json['metodo_acceso'],
      ubicacion: json['ubicacion'],
      observaciones: json['observaciones'],
      permitido: json['permitido'],
    );
  }
}

class IncidenteSeguridad {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fechaHora;
  final String tipoIncidente;
  final String prioridad;
  final String estado;
  final int reportadoPor;
  final String? ubicacion;
  final List<String>? evidencias;
  final String? accionesTomadas;

  IncidenteSeguridad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.tipoIncidente,
    required this.prioridad,
    required this.estado,
    required this.reportadoPor,
    this.ubicacion,
    this.evidencias,
    this.accionesTomadas,
  });

  factory IncidenteSeguridad.fromJson(Map<String, dynamic> json) {
    return IncidenteSeguridad(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaHora: DateTime.parse(json['fecha_hora']),
      tipoIncidente: json['tipo_incidente'],
      prioridad: json['prioridad'],
      estado: json['estado'],
      reportadoPor: json['reportado_por'],
      ubicacion: json['ubicacion'],
      evidencias: json['evidencias']?.cast<String>(),
      accionesTomadas: json['acciones_tomadas'],
    );
  }
}

class Visitante {
  final int id;
  final String nombre;
  final String? apellido;
  final String? identificacion;
  final String? telefono;
  final int propiedadVisitada;
  final DateTime fechaEntrada;
  final DateTime? fechaSalida;
  final String estado;
  final String? observaciones;
  final int? autorizadoPor;
  final String? qrCode;

  Visitante({
    required this.id,
    required this.nombre,
    this.apellido,
    this.identificacion,
    this.telefono,
    required this.propiedadVisitada,
    required this.fechaEntrada,
    this.fechaSalida,
    required this.estado,
    this.observaciones,
    this.autorizadoPor,
    this.qrCode,
  });

  factory Visitante.fromJson(Map<String, dynamic> json) {
    return Visitante(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      identificacion: json['identificacion'],
      telefono: json['telefono'],
      propiedadVisitada: json['propiedad_visitada'],
      fechaEntrada: DateTime.parse(json['fecha_entrada']),
      fechaSalida: json['fecha_salida'] != null
          ? DateTime.parse(json['fecha_salida'])
          : null,
      estado: json['estado'],
      observaciones: json['observaciones'],
      autorizadoPor: json['autorizado_por'],
      qrCode: json['qr_code'],
    );
  }
}

// ============== MANTENIMIENTO ==============
class SolicitudMantenimiento {
  final int id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;
  final String estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaEstimada;
  final DateTime? fechaCompletado;
  final int solicitadoPor;
  final int? asignadoA;
  final double? costoEstimado;
  final double? costoReal;
  final List<String>? evidencias;
  final String? observaciones;

  SolicitudMantenimiento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaEstimada,
    this.fechaCompletado,
    required this.solicitadoPor,
    this.asignadoA,
    this.costoEstimado,
    this.costoReal,
    this.evidencias,
    this.observaciones,
  });

  factory SolicitudMantenimiento.fromJson(Map<String, dynamic> json) {
    return SolicitudMantenimiento(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      prioridad: json['prioridad'],
      estado: json['estado'],
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      fechaEstimada: json['fecha_estimada'] != null
          ? DateTime.parse(json['fecha_estimada'])
          : null,
      fechaCompletado: json['fecha_completado'] != null
          ? DateTime.parse(json['fecha_completado'])
          : null,
      solicitadoPor: json['solicitado_por'],
      asignadoA: json['asignado_a'],
      costoEstimado: json['costo_estimado']?.toDouble(),
      costoReal: json['costo_real']?.toDouble(),
      evidencias: json['evidencias']?.cast<String>(),
      observaciones: json['observaciones'],
    );
  }
}

class TrabajadorMantenimiento {
  final int id;
  final String nombre;
  final String apellido;
  final String? telefono;
  final String? email;
  final String especialidad;
  final bool disponible;
  final String? horarioLaboral;

  TrabajadorMantenimiento({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.telefono,
    this.email,
    required this.especialidad,
    this.disponible = true,
    this.horarioLaboral,
  });

  factory TrabajadorMantenimiento.fromJson(Map<String, dynamic> json) {
    return TrabajadorMantenimiento(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      email: json['email'],
      especialidad: json['especialidad'],
      disponible: json['disponible'] ?? true,
      horarioLaboral: json['horario_laboral'],
    );
  }
}

class EquipoMantenimiento {
  final int id;
  final String nombre;
  final String? descripcion;
  final String estado;
  final DateTime? fechaAdquisicion;
  final DateTime? fechaUltimoMantenimiento;
  final DateTime? fechaProximoMantenimiento;
  final String? ubicacion;
  final double? costo;

  EquipoMantenimiento({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
    this.fechaAdquisicion,
    this.fechaUltimoMantenimiento,
    this.fechaProximoMantenimiento,
    this.ubicacion,
    this.costo,
  });

  factory EquipoMantenimiento.fromJson(Map<String, dynamic> json) {
    return EquipoMantenimiento(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      fechaAdquisicion: json['fecha_adquisicion'] != null
          ? DateTime.parse(json['fecha_adquisicion'])
          : null,
      fechaUltimoMantenimiento: json['fecha_ultimo_mantenimiento'] != null
          ? DateTime.parse(json['fecha_ultimo_mantenimiento'])
          : null,
      fechaProximoMantenimiento: json['fecha_proximo_mantenimiento'] != null
          ? DateTime.parse(json['fecha_proximo_mantenimiento'])
          : null,
      ubicacion: json['ubicacion'],
      costo: json['costo']?.toDouble(),
    );
  }
}

// ============== COMUNICACIONES ==============
class MensajeDirecto {
  final int id;
  final String asunto;
  final String contenido;
  final int remitente;
  final int destinatario;
  final DateTime fechaEnvio;
  final bool leido;
  final String? prioridad;

  MensajeDirecto({
    required this.id,
    required this.asunto,
    required this.contenido,
    required this.remitente,
    required this.destinatario,
    required this.fechaEnvio,
    this.leido = false,
    this.prioridad,
  });

  factory MensajeDirecto.fromJson(Map<String, dynamic> json) {
    return MensajeDirecto(
      id: json['id'],
      asunto: json['asunto'],
      contenido: json['contenido'],
      remitente: json['remitente'],
      destinatario: json['destinatario'],
      fechaEnvio: DateTime.parse(json['fecha_envio']),
      leido: json['leido'] ?? false,
      prioridad: json['prioridad'],
    );
  }
}

class NotificacionPush {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final int? usuario;
  final DateTime fechaEnvio;
  final bool enviado;
  final String? datosAdicionales;

  NotificacionPush({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.usuario,
    required this.fechaEnvio,
    this.enviado = false,
    this.datosAdicionales,
  });

  factory NotificacionPush.fromJson(Map<String, dynamic> json) {
    return NotificacionPush(
      id: json['id'],
      titulo: json['titulo'],
      mensaje: json['mensaje'],
      tipo: json['tipo'],
      usuario: json['usuario'],
      fechaEnvio: DateTime.parse(json['fecha_envio']),
      enviado: json['enviado'] ?? false,
      datosAdicionales: json['datos_adicionales'],
    );
  }
}

// ============== AUDITORIA ==============
class BitacoraAuditoria {
  final int id;
  final int usuario;
  final String accion;
  final String tabla;
  final int? objetoId;
  final Map<String, dynamic>? valoresAnteriores;
  final Map<String, dynamic>? valoresNuevos;
  final DateTime timestamp;
  final String? direccionIp;
  final String? userAgent;

  BitacoraAuditoria({
    required this.id,
    required this.usuario,
    required this.accion,
    required this.tabla,
    this.objetoId,
    this.valoresAnteriores,
    this.valoresNuevos,
    required this.timestamp,
    this.direccionIp,
    this.userAgent,
  });

  factory BitacoraAuditoria.fromJson(Map<String, dynamic> json) {
    return BitacoraAuditoria(
      id: json['id'],
      usuario: json['usuario'],
      accion: json['accion'],
      tabla: json['tabla'],
      objetoId: json['objeto_id'],
      valoresAnteriores: json['valores_anteriores'],
      valoresNuevos: json['valores_nuevos'],
      timestamp: DateTime.parse(json['timestamp']),
      direccionIp: json['direccion_ip'],
      userAgent: json['user_agent'],
    );
  }
}
