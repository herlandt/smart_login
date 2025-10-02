/// Configuración de endpoints para la API del Sistema de Gestión de Condominios
/// Basado en el Schema OpenAPI actualizado 2025
class EndpointsActualizados {
  // 🏠 BASE URL - Ajusta según tu configuración
  static const String baseUrl = 'http://10.0.2.2:8000';

  // 🔐 AUTENTICACIÓN Y USUARIOS
  static const String login = '/api/login/';
  static const String logout = '/api/logout/'; // Si existe en tu backend
  static const String registro = '/api/registro/';
  static const String usuariosPerfil = '/api/usuarios/perfil/';
  static const String usuariosResidentes = '/api/usuarios/residentes/';
  static const String usuariosRegistrarRostro =
      '/api/usuarios/reconocimiento/registrar-rostro/';
  static const String usuariosCrearAdmin =
      '/api/usuarios/setup/crear-primer-admin/';

  // 🏢 CONDOMINIOS Y PROPIEDADES
  static const String condominioAvisos = '/api/condominio/avisos/';
  static const String condominioPropiedades = '/api/condominio/propiedades/';
  static const String condominioReglas = '/api/condominio/reglas/';
  static const String condominioAreasComunes = '/api/condominio/areas-comunes/';

  // 💰 FINANZAS
  static const String finanzasGastos = '/api/finanzas/gastos/';
  static const String finanzasPagos = '/api/finanzas/pagos/';
  static const String finanzasIngresos = '/api/finanzas/ingresos/';
  static const String finanzasEgresos = '/api/finanzas/egresos/';
  static const String finanzasMultas = '/api/finanzas/multas/';
  static const String finanzasPagosMultas = '/api/finanzas/pagos-multas/';
  static const String finanzasReservas = '/api/finanzas/reservas/';
  static const String finanzasEstadoCuenta = '/api/finanzas/estado-de-cuenta/';
  static const String finanzasExpensasGenerar =
      '/api/finanzas/expensas/generar/';
  static const String finanzasReporteResumen =
      '/api/finanzas/reportes/resumen/';
  static const String finanzasReporteFinanciero =
      '/api/finanzas/reportes/financiero/';
  static const String finanzasReporteMorosidad =
      '/api/finanzas/reportes/estado-morosidad/';
  static const String finanzasReporteAreasComunes =
      '/api/finanzas/reportes/uso-areas-comunes/';

  // 🛡️ SEGURIDAD
  static const String seguridadVisitantes = '/api/seguridad/visitantes/';
  static const String seguridadVisitas = '/api/seguridad/visitas/';
  static const String seguridadVisitasAbiertas =
      '/api/seguridad/visitas-abiertas/';
  static const String seguridadVehiculos = '/api/seguridad/vehiculos/';
  static const String seguridadEventos = '/api/seguridad/eventos/';
  static const String seguridadDetecciones = '/api/seguridad/detecciones/';
  static const String seguridadControlAccesoVehicular =
      '/api/seguridad/control-acceso-vehicular/';
  static const String seguridadControlSalidaVehicular =
      '/api/seguridad/control-salida-vehicular/';
  static const String seguridadDashboardResumen =
      '/api/seguridad/dashboard/resumen/';
  static const String seguridadDashboardSeries =
      '/api/seguridad/dashboard/series/';
  static const String seguridadDashboardTopVisitantes =
      '/api/seguridad/dashboard/top-visitantes/';
  static const String seguridadExportVisitas =
      '/api/seguridad/export/visitas.csv';
  static const String seguridadCerrarVisitasVencidas =
      '/api/seguridad/cerrar-visitas-vencidas/';

  // 🤖 IA SEGURIDAD
  static const String seguridadIAControlVehicular =
      '/api/seguridad/ia/control-vehicular/';
  static const String seguridadIAVerificarRostro =
      '/api/seguridad/ia/verificar-rostro/';

  // 🔧 MANTENIMIENTO
  static const String mantenimientoSolicitudes =
      '/api/mantenimiento/solicitudes/';
  static const String mantenimientoPersonal = '/api/mantenimiento/personal/';

  // 📱 NOTIFICACIONES
  static const String notificacionesDemo = '/api/notificaciones/demo/';
  static const String notificacionesRegistrarDispositivo =
      '/api/notificaciones/registrar-dispositivo/';
  static const String notificacionesToken = '/api/notificaciones/token/';
  static const String dispositivosRegistrar = '/api/dispositivos/registrar/';

  // 📊 AUDITORÍA
  static const String auditoriaBitacora = '/api/auditoria/bitacora/';

  // 🔍 API SCHEMA Y DOCUMENTACIÓN
  static const String api = '/api/';
  static const String apiSchema = '/api/schema/';
  static const String apiSwagger = '/api/schema/swagger-ui/';
  static const String apiRedoc = '/api/schema/redoc/';

  // 💳 WEBHOOKS Y PAGOS
  static const String finanzasWebhookPagosnet =
      '/api/finanzas/webhook/pagosnet/';

  // 🎯 MÉTODOS AUXILIARES

  /// Construye URL completa
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// URL para detalle de un recurso específico
  static String buildDetailUrl(String endpoint, int id) {
    return '$baseUrl$endpoint$id/';
  }

  /// URL para acciones específicas en un recurso
  static String buildActionUrl(String endpoint, int id, String action) {
    return '$baseUrl$endpoint$id/$action/';
  }

  // 🔧 ENDPOINTS DINÁMICOS COMUNES

  /// Registrar pago para gasto específico
  static String gastoRegistrarPago(int gastoId) =>
      buildActionUrl(finanzasGastos, gastoId, 'registrar_pago');

  /// Crear gastos mensuales
  static String gastosCrearMensual() =>
      '${buildUrl(finanzasGastos)}crear_mensual/';

  /// Pagar gastos en lote
  static String gastosPagarEnLote() =>
      '${buildUrl(finanzasGastos)}pagar_en_lote/';

  /// Registrar pago para multa específica
  static String multaRegistrarPago(int multaId) =>
      buildActionUrl(finanzasMultas, multaId, 'registrar_pago');

  /// Pagar multas en lote
  static String multasPagarEnLote() =>
      '${buildUrl(finanzasMultas)}pagar_en_lote/';

  /// Asignar solicitud de mantenimiento
  static String mantenimientoAsignar(int solicitudId) =>
      buildActionUrl(mantenimientoSolicitudes, solicitudId, 'asignar');

  /// Cambiar estado de solicitud de mantenimiento
  static String mantenimientoCambiarEstado(int solicitudId) =>
      buildActionUrl(mantenimientoSolicitudes, solicitudId, 'cambiar_estado');

  /// Pagar reserva específica
  static String reservaPagar(int reservaId) =>
      buildActionUrl(finanzasReservas, reservaId, 'pagar');

  /// Comprobante de pago
  static String pagoComprobante(int pagoId) =>
      '${buildUrl(finanzasPagos)}$pagoId/comprobante/';

  /// Comprobante de pago de multa
  static String pagoMultaComprobante(int pagoMultaId) =>
      '${buildUrl(finanzasPagosMultas)}$pagoMultaId/comprobante/';

  /// Simular pago
  static String pagoSimular(int pagoId) =>
      '${buildUrl(finanzasPagos)}$pagoId/simular/';
}

/// Mapeo de endpoints legados a los nuevos endpoints
class EndpointsCompatibility {
  // Mapeo de endpoints anteriores a los nuevos
  static const Map<String, String> endpointMapping = {
    '/api/auth/login/': '/api/login/',
    '/api/perfil-usuario/': '/api/usuarios/perfil/',
    '/api/avisos/': '/api/condominio/avisos/',
    '/api/mantenimiento/': '/api/mantenimiento/solicitudes/',
    '/api/seguridad/': '/api/seguridad/visitantes/',
    '/api/finanzas/': '/api/finanzas/gastos/',
  };

  /// Convierte endpoint anterior al nuevo formato
  static String convertLegacyEndpoint(String legacyEndpoint) {
    return endpointMapping[legacyEndpoint] ?? legacyEndpoint;
  }
}
