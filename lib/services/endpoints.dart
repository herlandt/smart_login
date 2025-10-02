class Endpoints {
  // URL base del servidor - IP DE LA PC PARA ANDROID
  static const String baseUrl = "http://192.168.0.5:8000/api";

  // ============== AUTENTICACION ==============
  static const String login = "/login/";
  static const String welcome = "/welcome/";
  static const String authStatus = "/auth/status/";

  // ============== USUARIOS ==============
  static const String usuarios = "/usuarios/";
  static const String usuariosAll = "/usuarios/all/";
  static const String usuariosAdministradores = "/usuarios/administradores/";
  static const String usuariosResidentes = "/usuarios/residentes/";
  static const String usuariosPorteros = "/usuarios/porteros/";
  static const String usuariosMantenimiento = "/usuarios/mantenimiento/";
  static const String usuariosCreate = "/usuarios/create/";
  static const String usuariosUpdate = "/usuarios/update/";
  static const String usuariosDelete = "/usuarios/delete/";
  static const String usuariosFilters = "/usuarios/filters/";
  static const String usuariosValidate = "/usuarios/validate/";

  // ============== PROPIEDADES ==============
  static const String propiedades = "/propiedades/";
  static const String propiedadesResidentes = "/propiedades/residentes/";
  static const String propiedadesCreate = "/propiedades/create/";
  static const String propiedadesUpdate = "/propiedades/update/";
  static const String propiedadesDelete = "/propiedades/delete/";
  static const String propiedadesFilters = "/propiedades/filters/";
  static const String propiedadesValidate = "/propiedades/validate/";

  // ============== AREAS COMUNES ==============
  static const String areasComunes = "/areas-comunes/";
  static const String aresComunesCreate = "/areas-comunes/create/";
  static const String aresComunesUpdate = "/areas-comunes/update/";
  static const String aresComunesDelete = "/areas-comunes/delete/";
  static const String aresComunesDisponibilidad =
      "/areas-comunes/disponibilidad/";
  static const String aresComunesReservas = "/areas-comunes/reservas/";

  // ============== AVISOS ==============
  static const String avisos = "/avisos/";
  static const String avisosCreate = "/avisos/create/";
  static const String avisosUpdate = "/avisos/update/";
  static const String avisosDelete = "/avisos/delete/";
  static const String avisosFilters = "/avisos/filters/";

  // ============== REGLAS ==============
  static const String reglas = "/reglas/";
  static const String reglasCreate = "/reglas/create/";
  static const String reglasUpdate = "/reglas/update/";
  static const String reglasDelete = "/reglas/delete/";
  static const String reglasFilters = "/reglas/filters/";

  // ============== FINANZAS ==============
  // Gastos
  static const String gastos = "/finanzas/gastos/";
  static const String gastosListCreate = "/finanzas/gastos/";
  static const String gastosDetail = "/finanzas/gastos/{id}/";
  static const String gastosFilters = "/finanzas/gastos/filters/";
  static const String gastosValidate = "/finanzas/gastos/validate/";
  static const String gastosResumen = "/finanzas/gastos/resumen/";

  // Multas
  static const String multas = "/finanzas/multas/";
  static const String multasListCreate = "/finanzas/multas/";
  static const String multasDetail = "/finanzas/multas/{id}/";
  static const String multasFilters = "/finanzas/multas/filters/";
  static const String multasValidate = "/finanzas/multas/validate/";
  static const String multasResumen = "/finanzas/multas/resumen/";

  // Pagos
  static const String pagos = "/finanzas/pagos/";
  static const String pagosListCreate = "/finanzas/pagos/";
  static const String pagosDetail = "/finanzas/pagos/{id}/";
  static const String pagosFilters = "/finanzas/pagos/filters/";
  static const String pagosValidate = "/finanzas/pagos/validate/";
  static const String pagosQr = "/finanzas/pagos/qr/";

  // Reservas
  static const String reservas = "/finanzas/reservas/";
  static const String reservasListCreate = "/finanzas/reservas/";
  static const String reservasDetail = "/finanzas/reservas/{id}/";
  static const String reservasFilters = "/finanzas/reservas/filters/";
  static const String reservasValidate = "/finanzas/reservas/validate/";
  static const String reservasDisponibilidad =
      "/finanzas/reservas/disponibilidad/";

  // Estado de cuenta (CORREGIDO: usar endpoint correcto)
  static const String estadoCuenta = "/finanzas/estado-de-cuenta/";
  static const String estadoCuentaDetalle =
      "/finanzas/estado-de-cuenta/detalle/";
  static const String estadoCuentaResumen =
      "/finanzas/estado-de-cuenta/resumen/";

  // Ingresos y Egresos
  static const String ingresosListCreate = "/finanzas/ingresos/";
  static const String ingresosDetail = "/finanzas/ingresos/{id}/";
  static const String egresosListCreate = "/finanzas/egresos/";
  static const String egresosDetail = "/finanzas/egresos/{id}/";

  // ============== SEGURIDAD ==============
  // Accesos
  static const String accesosListCreate = "/seguridad/accesos/";
  static const String accesosDetail = "/seguridad/accesos/{id}/";
  static const String accesosFilters = "/seguridad/accesos/filters/";
  static const String accesosValidate = "/seguridad/accesos/validate/";
  static const String accesosRegistros = "/seguridad/accesos/registros/";
  static const String accesosQr = "/seguridad/accesos/qr/";

  // Visitas (CORREGIDO: era "visitantes")
  static const String visitantes = "/seguridad/visitas/";
  static const String visitasListCreate = "/seguridad/visitas/";
  static const String visitasDetail = "/seguridad/visitas/{id}/";
  static const String visitasFilters = "/seguridad/visitas/filters/";
  static const String visitasValidate = "/seguridad/visitas/validate/";
  static const String visitasQr = "/seguridad/visitas/qr/";
  static const String visitasAutorizar = "/seguridad/visitas/autorizar/";

  // Eventos de Seguridad (CORREGIDO: usar endpoint exacto del backend)
  static const String eventosSeguridad = "/seguridad/eventos/";
  static const String eventosSeguridadDetail = "/seguridad/eventos/{id}/";
  static const String eventosSeguridadFilters = "/seguridad/eventos/filters/";

  // Vehiculos
  static const String vehiculos = "/seguridad/vehiculos/";
  static const String vehiculosDetail = "/seguridad/vehiculos/{id}/";

  // Detecciones y Control IA
  static const String detecciones = "/seguridad/detecciones/";
  static const String verificarRostro =
      "/seguridad/verificar-rostro/"; // CORREGIDO: sin "/ia/"
  static const String controlVehicular = "/seguridad/control-acceso-vehicular/";
  static const String controlSalidaVehicular =
      "/seguridad/control-salida-vehicular/";

  // ============== MANTENIMIENTO ==============
  // Solicitudes
  static const String mantSolicitudes = "/mantenimiento/solicitudes/";
  static const String solicitudesListCreate = "/mantenimiento/solicitudes/";
  static const String solicitudesDetail = "/mantenimiento/solicitudes/{id}/";
  static const String solicitudesFilters =
      "/mantenimiento/solicitudes/filters/";
  static const String solicitudesValidate =
      "/mantenimiento/solicitudes/validate/";
  static const String solicitudesAsignar =
      "/mantenimiento/solicitudes/asignar/";
  static const String solicitudesCompletar =
      "/mantenimiento/solicitudes/completar/";

  // Trabajadores
  static const String trabajadoresListCreate = "/mantenimiento/trabajadores/";
  static const String trabajadoresDetail = "/mantenimiento/trabajadores/{id}/";
  static const String trabajadoresFilters =
      "/mantenimiento/trabajadores/filters/";
  static const String trabajadoresDisponibles =
      "/mantenimiento/trabajadores/disponibles/";

  // Equipos
  static const String equiposListCreate = "/mantenimiento/equipos/";
  static const String equiposDetail = "/mantenimiento/equipos/{id}/";
  static const String equiposFilters = "/mantenimiento/equipos/filters/";
  static const String equiposMantenimiento =
      "/mantenimiento/equipos/mantenimiento/";

  // ============== COMUNICACIONES ==============
  // Mensajes directos
  static const String mensajesListCreate = "/comunicaciones/mensajes/";
  static const String mensajesDetail = "/comunicaciones/mensajes/{id}/";
  static const String mensajesFilters = "/comunicaciones/mensajes/filters/";
  static const String mensajesMarcarLeido =
      "/comunicaciones/mensajes/marcar-leido/";

  // Notificaciones push
  static const String notificacionesListCreate =
      "/comunicaciones/notificaciones/";
  static const String notificacionesDetail =
      "/comunicaciones/notificaciones/{id}/";
  static const String notificacionesEnviar =
      "/comunicaciones/notificaciones/enviar/";
  static const String notificacionesConfig =
      "/comunicaciones/notificaciones/config/";

  // Notificaciones endpoints adicionales (AGREGADO: estaban faltantes)
  static const String notificacionesToken = "/notificaciones/token/";
  static const String notificacionesDemo = "/notificaciones/demo/";
  static const String notificacionesRegistrarDispositivo =
      "/notificaciones/registrar-dispositivo/";
  static const String registrarDeviceToken = "/notificaciones/device-token/";
  static const String notificacionesMarcarLeida =
      "/notificaciones/marcar-leida/";

  // ============== AUDITORIA ==============
  static const String auditoriaBitacora = "/auditoria/bitacora/";
  static const String auditoriaDetail = "/auditoria/bitacora/{id}/";
  static const String auditoriaFilters = "/auditoria/bitacora/filters/";
  static const String auditoriaReportes = "/auditoria/reportes/";
  static const String auditoriaExportar = "/auditoria/exportar/";

  // ============== REPORTES Y ESTADISTICAS ==============
  static const String reportesGeneral = "/reportes/";
  static const String reportesFinancieros = "/reportes/financieros/";
  static const String reportesSeguridad = "/reportes/seguridad/";
  static const String reportesMantenimiento = "/reportes/mantenimiento/";
  static const String estadisticasGeneral = "/estadisticas/";
  static const String estadisticasUsuarios = "/estadisticas/usuarios/";
  static const String estadisticasFinanzas = "/estadisticas/finanzas/";

  // ============== CONFIGURACION ==============
  static const String configuracion = "/configuracion/";
  static const String configuracionSistema = "/configuracion/sistema/";
  static const String configuracionNotificaciones =
      "/configuracion/notificaciones/";
  static const String configuracionSeguridad = "/configuracion/seguridad/";

  // ============== UTILIDADES ==============
  static const String validarToken = "/utils/validar-token/";
  static const String generarQr = "/utils/generar-qr/";
  static const String uploadFile = "/utils/upload/";
  static const String downloadFile = "/utils/download/";
  static const String backup = "/utils/backup/";
  static const String restore = "/utils/restore/";

  // Método helper para reemplazar parámetros en URLs
  static String replacePathParams(
    String endpoint,
    Map<String, dynamic> params,
  ) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
