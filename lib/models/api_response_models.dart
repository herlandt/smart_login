// Modelos de respuesta unificados para manejar todas las respuestas de la API

// ============== RESPUESTAS GENERICAS ==============
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      statusCode: json['status_code'],
    );
  }
}

class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
    );
  }
}

// ============== RESPUESTAS ESPECIFICAS ==============
class WelcomeResponse {
  final String message;
  final String username;
  final String userType;
  final DateTime timestamp;
  final List<String>? permissions;

  WelcomeResponse({
    required this.message,
    required this.username,
    required this.userType,
    required this.timestamp,
    this.permissions,
  });

  factory WelcomeResponse.fromJson(Map<String, dynamic> json) {
    return WelcomeResponse(
      message: json['message'],
      username: json['username'],
      userType: json['user_type'],
      timestamp: DateTime.parse(json['timestamp']),
      permissions: json['permissions']?.cast<String>(),
    );
  }
}

class AuthStatusResponse {
  final bool isAuthenticated;
  final String? username;
  final String? userType;
  final DateTime? lastLogin;
  final bool tokenValid;

  AuthStatusResponse({
    required this.isAuthenticated,
    this.username,
    this.userType,
    this.lastLogin,
    required this.tokenValid,
  });

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) {
    return AuthStatusResponse(
      isAuthenticated: json['is_authenticated'],
      username: json['username'],
      userType: json['user_type'],
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      tokenValid: json['token_valid'],
    );
  }
}

class QRCodeResponse {
  final String qrData;
  final String qrImage; // Base64 encoded image
  final DateTime expiresAt;
  final String purpose; // acceso, pago, reserva, etc.

  QRCodeResponse({
    required this.qrData,
    required this.qrImage,
    required this.expiresAt,
    required this.purpose,
  });

  factory QRCodeResponse.fromJson(Map<String, dynamic> json) {
    return QRCodeResponse(
      qrData: json['qr_data'],
      qrImage: json['qr_image'],
      expiresAt: DateTime.parse(json['expires_at']),
      purpose: json['purpose'],
    );
  }
}

class StatisticsResponse {
  final Map<String, dynamic> data;
  final DateTime generatedAt;
  final String period;

  StatisticsResponse({
    required this.data,
    required this.generatedAt,
    required this.period,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      data: json['data'],
      generatedAt: DateTime.parse(json['generated_at']),
      period: json['period'],
    );
  }
}

// ============== RESPUESTAS DE FILTROS ==============
class FilterOptions {
  final List<String> estados;
  final List<String> categorias;
  final List<String> prioridades;
  final List<String> tiposUsuario;
  final Map<String, dynamic>? ranges;

  FilterOptions({
    required this.estados,
    required this.categorias,
    required this.prioridades,
    required this.tiposUsuario,
    this.ranges,
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      estados: json['estados']?.cast<String>() ?? [],
      categorias: json['categorias']?.cast<String>() ?? [],
      prioridades: json['prioridades']?.cast<String>() ?? [],
      tiposUsuario: json['tipos_usuario']?.cast<String>() ?? [],
      ranges: json['ranges'],
    );
  }
}

// ============== RESPUESTAS DE VALIDACION ==============
class ValidationResponse {
  final bool isValid;
  final List<String>? errors;
  final Map<String, List<String>>? fieldErrors;

  ValidationResponse({required this.isValid, this.errors, this.fieldErrors});

  factory ValidationResponse.fromJson(Map<String, dynamic> json) {
    return ValidationResponse(
      isValid: json['is_valid'],
      errors: json['errors']?.cast<String>(),
      fieldErrors: json['field_errors']?.map<String, List<String>>(
        (key, value) => MapEntry(key, value.cast<String>()),
      ),
    );
  }
}

// ============== RESPUESTAS DE REPORTES ==============
class ReportResponse {
  final String reportId;
  final String title;
  final String format; // PDF, Excel, CSV
  final String? downloadUrl;
  final Map<String, dynamic>? summary;
  final DateTime generatedAt;
  final String status; // generating, ready, error

  ReportResponse({
    required this.reportId,
    required this.title,
    required this.format,
    this.downloadUrl,
    this.summary,
    required this.generatedAt,
    required this.status,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      reportId: json['report_id'],
      title: json['title'],
      format: json['format'],
      downloadUrl: json['download_url'],
      summary: json['summary'],
      generatedAt: DateTime.parse(json['generated_at']),
      status: json['status'],
    );
  }
}

// ============== RESPUESTAS DE CONFIGURACION ==============
class ConfigurationResponse {
  final Map<String, dynamic> settings;
  final DateTime lastUpdated;
  final String version;

  ConfigurationResponse({
    required this.settings,
    required this.lastUpdated,
    required this.version,
  });

  factory ConfigurationResponse.fromJson(Map<String, dynamic> json) {
    return ConfigurationResponse(
      settings: json['settings'],
      lastUpdated: DateTime.parse(json['last_updated']),
      version: json['version'],
    );
  }
}

// ============== MODELOS DE SOLICITUD (REQUEST) ==============
class CreateGastoRequest {
  final String concepto;
  final double monto;
  final DateTime fechaVencimiento;
  final int propiedad;
  final String? descripcion;

  CreateGastoRequest({
    required this.concepto,
    required this.monto,
    required this.fechaVencimiento,
    required this.propiedad,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'concepto': concepto,
      'monto': monto,
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'propiedad': propiedad,
      'descripcion': descripcion,
    };
  }
}

class CreateMultaRequest {
  final String concepto;
  final double monto;
  final DateTime fechaVencimiento;
  final int propiedad;
  final String? descripcion;
  final String? motivo;

  CreateMultaRequest({
    required this.concepto,
    required this.monto,
    required this.fechaVencimiento,
    required this.propiedad,
    this.descripcion,
    this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'concepto': concepto,
      'monto': monto,
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'propiedad': propiedad,
      'descripcion': descripcion,
      'motivo': motivo,
    };
  }
}

class CreateReservaRequest {
  final int areaComun;
  final DateTime fechaReserva;
  final String horaInicio;
  final String horaFin;
  final String? observaciones;

  CreateReservaRequest({
    required this.areaComun,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    this.observaciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'area_comun': areaComun,
      'fecha_reserva': fechaReserva.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'observaciones': observaciones,
    };
  }
}

class CreateSolicitudMantenimientoRequest {
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;

  CreateSolicitudMantenimientoRequest({
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'prioridad': prioridad,
    };
  }
}
