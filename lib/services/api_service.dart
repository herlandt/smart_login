import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';

class ApiService {
  ApiService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Token $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('${Endpoints.base}${Endpoints.login}');
    final res = await http.post(
      uri,
      headers: await _headers(withAuth: false),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login ${res.statusCode}: ${res.body}');
  }

  Future<dynamic> get(String endpoint, {List<String>? candidates}) async {
    final headers = await _headers();
    final List<String> rutas = candidates ?? [endpoint];
    Exception? lastErr;
    for (final ep in rutas) {
      final uri = Uri.parse(
        '${Endpoints.base.replaceAll(RegExp(r"/$"), "")}${ep.startsWith("/") ? ep : "/$ep"}',
      );
      try {
        final res = await http.get(uri, headers: headers);
        if (res.statusCode == 200) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          lastErr = Exception('GET $ep → ${res.statusCode}\n${res.body}');
        }
      } catch (e) {
        lastErr = Exception('$e');
      }
    }
    throw lastErr ?? Exception('No se pudo obtener datos de $endpoint');
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    List<String>? candidates,
    bool withAuth = true,
  }) async {
    final headers = await _headers(withAuth: withAuth);
    final List<String> rutas = candidates ?? [endpoint];
    Exception? lastErr;
    for (final ep in rutas) {
      final uri = Uri.parse(
        '${Endpoints.base.replaceAll(RegExp(r"/$"), "")}${ep.startsWith("/") ? ep : "/$ep"}',
      );
      try {
        final res = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(data),
        );
        if (res.statusCode == 200 || res.statusCode == 201) {
          return jsonDecode(utf8.decode(res.bodyBytes));
        } else {
          lastErr = Exception('POST $ep → ${res.statusCode}\n${res.body}');
        }
      } catch (e) {
        lastErr = Exception('$e');
      }
    }
    throw lastErr ?? Exception('No se pudo enviar datos a $endpoint');
  }

  // lib/services/api_service.dart (añadir)
  Future<List<dynamic>> fetchSolicitudesMantenimiento() async {
    final res = await get(
      'api/mantenimiento/solicitudes/',
      candidates: [
        'api/mantenimiento/solicitudes/',
        'mantenimiento/solicitudes/',
        'mantenimiento/',
        'api/mantenimiento/',
        'solicitudes/',
      ],
    );
    return (res as List);
  }

  Future<Map<String, dynamic>> crearSolicitudMantenimiento({
    required String titulo,
    required String descripcion,
    String? prioridad,
    int? propiedadId,
  }) async {
    final payload = {
      'titulo': titulo,
      'descripcion': descripcion,
      if (prioridad != null) 'prioridad': prioridad,
      if (propiedadId != null) 'propiedad_id': propiedadId,
    };
    final res = await post(
      'api/mantenimiento/solicitudes/',
      payload,
      candidates: [
        'api/mantenimiento/solicitudes/',
        'mantenimiento/solicitudes/',
        'mantenimiento/',
        'api/mantenimiento/',
        'solicitudes/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  // Usuarios
  Future<Map<String, dynamic>> fetchPerfil() async {
    final res = await get(
      'api/usuarios/perfil/',
      candidates: [
        'api/usuarios/perfil/',
        'usuarios/perfil/',
        'perfil/',
        'api/perfil/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  Future<List<dynamic>> fetchPropiedadesUsuario() async {
    final res = await get(
      'api/condominio/propiedades/',
      candidates: [
        'api/condominio/propiedades/',
        'condominio/propiedades/',
        'propiedades/',
        'api/propiedades/',
      ],
    );
    return (res as List);
  }

  Future<Map<String, dynamic>> actualizarPerfil(
    Map<String, dynamic> data,
  ) async {
    final res = await post(
      'usuarios/actualizar/',
      data,
      candidates: [
        'usuarios/actualizar/',
        'actualizar-perfil/',
        'usuarios/update/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> cambiarPassword(
    String oldPassword,
    String newPassword,
  ) async {
    final res = await post(
      'usuarios/cambiar-password/',
      {'old_password': oldPassword, 'new_password': newPassword},
      candidates: [
        'usuarios/cambiar-password/',
        'cambiar-password/',
        'usuarios/change-password/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  // Seguridad
  Future<List<dynamic>> fetchVisitas() async {
    final res = await get(
      'api/seguridad/visitas/',
      candidates: [
        'api/seguridad/visitas/',
        'seguridad/visitas/',
        'visitas/',
        'api/visitas/',
      ],
    );
    return (res as List);
  }

  Future<Map<String, dynamic>> registrarVisita(
    Map<String, dynamic> data,
  ) async {
    final res = await post(
      'seguridad/visitas/',
      data,
      candidates: ['seguridad/visitas/', 'visitas/', 'seguridad/visit/'],
    );
    return (res as Map<String, dynamic>);
  }

  Future<List<dynamic>> fetchVehiculos() async {
    final res = await get(
      'seguridad/vehiculos/',
      candidates: ['seguridad/vehiculos/', 'vehiculos/', 'seguridad/vehicle/'],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchVisitantes() async {
    final res = await get(
      'seguridad/visitantes/',
      candidates: [
        'seguridad/visitantes/',
        'visitantes/',
        'seguridad/visitor/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchEventosSeguridad() async {
    final res = await get(
      'seguridad/eventos/',
      candidates: [
        'seguridad/eventos/',
        'eventos-seguridad/',
        'seguridad/event/',
      ],
    );
    return (res as List);
  }

  // Notificaciones
  Future<List<dynamic>> fetchNotificaciones() async {
    final res = await get(
      'notificaciones/',
      candidates: [
        'notificaciones/',
        'notificaciones-residente/',
        'notificaciones/avisos/',
      ],
    );
    return (res as List);
  }

  Future<Map<String, dynamic>> registrarDeviceToken(String token) async {
    final res = await post(
      'notificaciones/token/',
      {'token': token},
      candidates: [
        'notificaciones/token/',
        'notificaciones/device-token/',
        'notificaciones/register-token/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  // Condominio
  Future<List<dynamic>> fetchAvisos() async {
    final res = await get(
      'api/condominio/avisos/',
      candidates: [
        'api/condominio/avisos/',
        'condominio/avisos/',
        'avisos/',
        'api/avisos/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchPropiedades() async {
    final res = await get(
      'api/condominio/propiedades/',
      candidates: [
        'api/condominio/propiedades/',
        'condominio/propiedades/',
        'propiedades/',
        'api/propiedades/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchAreasComunes() async {
    final res = await get(
      'api/condominio/areas-comunes/',
      candidates: [
        'api/condominio/areas-comunes/',
        'condominio/areas-comunes/',
        'areas-comunes/',
        'api/areas-comunes/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchReglas() async {
    final res = await get(
      'api/condominio/reglas/',
      candidates: [
        'api/condominio/reglas/',
        'condominio/reglas/',
        'reglas/',
        'api/reglas/',
      ],
    );
    return (res as List);
  }

  // Finanzas
  Future<List<dynamic>> fetchGastos() async {
    final res = await get(
      'api/finanzas/gastos/',
      candidates: [
        'api/finanzas/gastos/',
        'finanzas/gastos/',
        'gastos/',
        'api/gastos/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchPagos() async {
    final res = await get(
      'api/finanzas/pagos/',
      candidates: [
        'api/finanzas/pagos/',
        'finanzas/pagos/',
        'pagos/',
        'api/pagos/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchMultas() async {
    final res = await get(
      'api/finanzas/multas/',
      candidates: [
        'api/finanzas/multas/',
        'finanzas/multas/',
        'multas/',
        'api/multas/',
      ],
    );
    return (res as List);
  }

  Future<List<dynamic>> fetchReservas() async {
    final res = await get(
      'api/finanzas/reservas/',
      candidates: [
        'api/finanzas/reservas/',
        'finanzas/reservas/',
        'reservas/',
        'api/reservas/',
      ],
    );
    return (res as List);
  }

  Future<Map<String, dynamic>> fetchEstadoDeCuenta() async {
    final res = await get(
      'finanzas/estado-de-cuenta/',
      candidates: [
        'finanzas/estado-de-cuenta/',
        'estado-de-cuenta/',
        'finanzas/account-status/',
        'api/finanzas/estado-de-cuenta/',
        'api/finanzas/',
        'finanzas/',
      ],
    );
    return (res as Map<String, dynamic>);
  }

  // Auditoría
  Future<List<dynamic>> fetchAuditoriaHistorial() async {
    final res = await get(
      'auditoria/historial/',
      candidates: [
        'auditoria/historial/',
        'historial-auditoria/',
        'auditoria/history/',
        'api/auditoria/historial/',
        'api/auditoria/',
        'auditoria/',
        'historial/',
      ],
    );
    return (res as List);
  }
}
