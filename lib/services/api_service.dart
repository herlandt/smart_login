import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://smart-condominium-backend-cg7l.onrender.com';

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

  // ============== MÉTODOS GENÉRICOS ==============
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw Exception('GET $endpoint → ${res.statusCode}: ${res.body}');
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw Exception('POST $endpoint → ${res.statusCode}: ${res.body}');
  }

  // ============== AUTENTICACIÓN ==============
  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$baseUrl/api/usuarios/login/');
    final res = await http.post(
      uri,
      headers: await _headers(withAuth: false),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['token'] != null) {
        return data;
      } else {
        throw Exception('Login exitoso pero sin token');
      }
    }
    throw Exception('Credenciales incorrectas');
  }

  Future<Map<String, dynamic>> registro(Map<String, dynamic> userData) async {
    return await post('/api/usuarios/registro/', userData)
        as Map<String, dynamic>;
  }

  Future<void> registrarDispositivo(String fcmToken) async {
    await post('/api/usuarios/dispositivos/registrar/', {
      'fcm_token': fcmToken,
    });
  }

  // ============== USUARIO Y PERFIL ==============
  Future<Map<String, dynamic>> getPerfilUsuario() async {
    return await get('/api/usuarios/perfil/') as Map<String, dynamic>;
  }

  // ============== FINANZAS ==============
  Future<List<dynamic>> fetchGastos() async {
    return await get('/api/finanzas/gastos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchPagos() async {
    return await get('/api/finanzas/pagos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchMultas() async {
    return await get('/api/finanzas/multas/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchEgresos() async {
    return await get('/api/finanzas/egresos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchIngresos() async {
    return await get('/api/finanzas/ingresos/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> pagarGasto(int gastoId) async {
    return await post('/api/finanzas/gastos/$gastoId/pagar/', {
          'metodo_pago': 'transferencia',
        })
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pagarMulta(int multaId) async {
    return await post('/api/finanzas/multas/$multaId/pagar/', {
          'metodo_pago': 'transferencia',
        })
        as Map<String, dynamic>;
  }

  // ============== CONDOMINIO ==============
  Future<List<dynamic>> fetchPropiedades() async {
    return await get('/api/condominio/propiedades/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchAreasComunes() async {
    return await get('/api/condominio/areas-comunes/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchAvisos() async {
    return await get('/api/condominio/avisos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchReglas() async {
    return await get('/api/condominio/reglas/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchReservas() async {
    return await get('/api/condominio/reservas/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearReserva(
    Map<String, dynamic> datosReserva,
  ) async {
    return await post('/api/condominio/reservas/', datosReserva)
        as Map<String, dynamic>;
  }

  Future<void> cancelarReserva(int reservaId) async {
    await post('/api/condominio/reservas/$reservaId/cancelar/', {});
  }

  // ============== SEGURIDAD ==============
  Future<List<dynamic>> fetchVehiculos() async {
    return await get('/api/seguridad/vehiculos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchVisitantes() async {
    return await get('/api/seguridad/visitantes/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchVisitas() async {
    return await get('/api/seguridad/visitas/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchEventosSeguridad() async {
    return await get('/api/seguridad/eventos/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> controlAccesoVehicular(String placa) async {
    return await post('/api/seguridad/control-acceso-vehicular/', {
          'placa': placa,
        })
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> controlSalidaVehicular(String placa) async {
    return await post('/api/seguridad/control-salida-vehicular/', {
          'placa': placa,
        })
        as Map<String, dynamic>;
  }

  Future<List<dynamic>> getVisitasAbiertas() async {
    return await get('/api/seguridad/visitas-abiertas/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> getDashboardResumen() async {
    return await get('/api/seguridad/dashboard/resumen/')
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> crearVisita(
    Map<String, dynamic> datosVisita,
  ) async {
    return await post('/api/seguridad/visitas/', datosVisita)
        as Map<String, dynamic>;
  }

  // ============== MANTENIMIENTO ==============
  Future<List<dynamic>> fetchSolicitudesMantenimiento() async {
    return await get('/api/mantenimiento/solicitudes/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchPersonalMantenimiento() async {
    return await get('/api/mantenimiento/personal/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> crearSolicitudMantenimiento(
    Map<String, dynamic> datos,
  ) async {
    return await post('/api/mantenimiento/solicitudes/', datos)
        as Map<String, dynamic>;
  }

  // ============== NOTIFICACIONES ==============
  Future<List<dynamic>> fetchNotificaciones() async {
    return await get('/api/notificaciones/') as List<dynamic>;
  }

  Future<void> marcarNotificacionLeida(int notificacionId) async {
    await post('/api/notificaciones/$notificacionId/marcar-leida/', {});
  }

  // ============== AUDITORÍA ==============
  Future<List<dynamic>> fetchHistorialAuditoria() async {
    return await get('/api/auditoria/historial/') as List<dynamic>;
  }

  Future<Map<String, dynamic>> getEstadisticasAuditoria() async {
    return await get('/api/auditoria/estadisticas/') as Map<String, dynamic>;
  }
}
