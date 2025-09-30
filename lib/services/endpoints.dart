class Endpoints {
  static const String base =
      'https://smart-condominium-backend-cg7l.onrender.com/api';

  // Auth
  static const String login = '/login/';

  // Usuarios
  static const String perfil = '/usuarios/perfil/';
  static const String cambiarPassword = '/usuarios/cambiar-password/';
  static const String actualizarUsuario = '/usuarios/actualizar/';

  // Mantenimiento
  static const String mantList = '/mantenimiento/solicitudes/';
  static const String mantCreate = '/mantenimiento/solicitudes/';
  static const String mantDetail = '/mantenimiento/solicitudes/{id}/';
  static const String mantCancel = '/mantenimiento/solicitudes/{id}/cancelar/';
  static const String mantPersonal = '/mantenimiento/personal/';

  // Seguridad
  static const String visitas = '/seguridad/visitas/';
  static const String vehiculos = '/seguridad/vehiculos/';
  static const String visitantes = '/seguridad/visitantes/';
  static const String eventosSeguridad = '/seguridad/eventos/';
  static const String controlAccesoVehicular =
      '/seguridad/control-acceso-vehicular/';
  static const String controlSalidaVehicular =
      '/seguridad/control-salida-vehicular/';
  static const String visitasAbiertas = '/seguridad/visitas-abiertas/';
  static const String exportVisitasCSV = '/seguridad/export/visitas.csv';
  static const String cerrarVisitasVencidas =
      '/seguridad/cerrar-visitas-vencidas/';
  static const String dashboardResumen = '/seguridad/dashboard/resumen/';
  static const String dashboardSeries = '/seguridad/dashboard/series/';
  static const String dashboardTopVisitantes =
      '/seguridad/dashboard/top-visitantes/';
  static const String iaControlVehicular = '/seguridad/ia/control-vehicular/';
  static const String iaVerificarRostro = '/seguridad/ia/verificar-rostro/';
  static const String detecciones = '/seguridad/detecciones/';

  // Notificaciones
  static const String notificaciones = '/notificaciones/';
  static const String notificacionDetail = '/notificaciones/{id}/';
  static const String registrarDeviceToken = '/notificaciones/token/';
  static const String enviarNotificacionDemo = '/notificaciones/demo/';
  static const String registrarDispositivo =
      '/notificaciones/registrar-dispositivo/';

  // Condominio
  static const String propiedades = '/condominio/propiedades/';
  static const String areasComunes = '/condominio/areas-comunes/';
  static const String avisos = '/condominio/avisos/';
  static const String reglas = '/condominio/reglas/';
  static const String condominioInfo = '/condominio/info/';
  static const String condominioReglamento = '/condominio/reglamento/';
  static const String condominioContacto = '/condominio/contacto/';

  // Finanzas
  static const String gastos = '/finanzas/gastos/';
  static const String pagos = '/finanzas/pagos/';
  static const String multas = '/finanzas/multas/';
  static const String pagosMultas = '/finanzas/pagos-multas/';
  static const String reservas = '/finanzas/reservas/';
  static const String egresos = '/finanzas/egresos/';
  static const String ingresos = '/finanzas/ingresos/';
  static const String reciboPagoPDF = '/finanzas/pagos/{pago_id}/comprobante/';
  static const String reciboPagoMultaPDF =
      '/finanzas/pagos-multas/{pago_multa_id}/comprobante/';
  static const String reporteMorosidad = '/finanzas/reportes/estado-morosidad/';
  static const String reporteResumen = '/finanzas/reportes/resumen/';
  static const String simularPago = '/finanzas/pagos/{pago_id}/simular/';
  static const String webhookPagosnet = '/finanzas/webhook/pagosnet/';
  static const String pagarReserva = '/finanzas/reservas/{reserva_id}/pagar/';
  static const String generarExpensas = '/finanzas/expensas/generar/';
  static const String estadoDeCuenta = '/finanzas/estado-de-cuenta/';
  static const String reporteFinanciero = '/finanzas/reportes/financiero/';
  static const String reporteUsoAreasComunes =
      '/finanzas/reportes/uso-areas-comunes/';

  // Auditoría
  static const String auditoriaHistorial = '/auditoria/historial/';
}
