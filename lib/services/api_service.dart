import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Usar URL base sin agregar /api para evitar duplicación
  String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'User-Agent': 'SmartLogin-Android-Emulator/1.0',
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
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    String query = '';
    if (queryParams != null) {
      query = queryParams.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
          )
          .join('&');
      query = query.isNotEmpty ? '?$query' : '';
    }

    final response = await http
        .get(Uri.parse('$baseUrl$endpoint$query'), headers: await _headers())
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          headers: await _headers(),
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  // ============== AUTENTICACIÓN ==============
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/login/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data['token']);
      return data;
    } else {
      throw Exception('Error de login: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<dynamic> getWelcomeInfo() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error: ${response.statusCode}');
  }

  // ============== FINANZAS ==============
  Future<List<dynamic>> fetchGastos() async {
    return await get('/finanzas/gastos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchPagos() async {
    return await get('/finanzas/pagos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchMultas() async {
    return await get('/finanzas/multas/') as List<dynamic>;
  }

  Future<void> pagarGasto(
    int gastoId, {
    double? montoPagado,
    String? metodoPago,
    String? referencia,
  }) async {
    final data = {
      'monto_pagado': montoPagado,
      'metodo_pago': metodoPago ?? 'transferencia',
      'referencia': referencia,
      'fecha_pago': DateTime.now().toIso8601String(),
    };
    await post('/finanzas/gastos/$gastoId/registrar_pago/', data);
  }

  Future<void> pagarMulta(
    int multaId, {
    double? montoPagado,
    String? metodoPago,
    String? referencia,
  }) async {
    final data = {
      'monto_pagado': montoPagado,
      'metodo_pago': metodoPago ?? 'transferencia',
      'referencia': referencia,
      'fecha_pago': DateTime.now().toIso8601String(),
    };
    await post('/finanzas/multas/$multaId/registrar_pago/', data);
  }

  // Pagos en lote
  Future<dynamic> pagarGastosEnLote(
    List<int> gastosIds, {
    String? metodoPago,
    String? referencia,
  }) async {
    final data = {
      'gastos_ids': gastosIds,
      'metodo_pago': metodoPago ?? 'transferencia',
      'referencia': referencia,
      'fecha_pago': DateTime.now().toIso8601String(),
    };
    return await post('/finanzas/gastos/pagar_en_lote/', data);
  }

  Future<dynamic> pagarMultasEnLote(
    List<int> multasIds, {
    String? metodoPago,
    String? referencia,
  }) async {
    final data = {
      'multas_ids': multasIds,
      'metodo_pago': metodoPago ?? 'transferencia',
      'referencia': referencia,
      'fecha_pago': DateTime.now().toIso8601String(),
    };
    return await post('/finanzas/multas/pagar_en_lote/', data);
  }

  // Simular pago
  Future<dynamic> simularPago(int pagoId) async {
    return await post('/finanzas/pagos/$pagoId/simular/', {});
  }

  // Obtener comprobante de pago
  Future<dynamic> obtenerComprobantePago(int pagoId) async {
    return await get('/finanzas/pagos/$pagoId/comprobante/');
  }

  Future<dynamic> obtenerComprbanteMulta(int pagoMultaId) async {
    return await get('/finanzas/pagos-multas/$pagoMultaId/comprobante/');
  }

  // ============== CONDOMINIO ==============
  Future<List<dynamic>> fetchPropiedades() async {
    return await get('/condominio/propiedades/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchAreasComunes() async {
    return await get('/condominio/areas-comunes/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchReglas() async {
    return await get('/reglas/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchReservas() async {
    return await get('/finanzas/reservas/') as List<dynamic>;
  }

  // ============== SEGURIDAD ==============
  Future<List<dynamic>> fetchVisitas() async {
    return await get('/seguridad/visitas/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchVehiculos() async {
    return await get('/seguridad/vehiculos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchEventosSeguridad() async {
    return await get('/seguridad/eventos/') as List<dynamic>;
  }

  // ============== MANTENIMIENTO ==============
  Future<List<dynamic>> fetchSolicitudesMantenimiento() async {
    return await get('/mantenimiento/solicitudes/') as List<dynamic>;
  }

  Future<dynamic> crearSolicitudMantenimiento(
    Map<String, dynamic> solicitud,
  ) async {
    return await post('/mantenimiento/solicitudes/', solicitud);
  }

  // ============== USUARIOS ==============
  Future<dynamic> getPerfilUsuario() async {
    return await get('/usuarios/perfil/');
  }

  // ============== COMUNICACIONES ==============
  Future<List<dynamic>> fetchAvisos() async {
    return await get('/comunicaciones/avisos/') as List<dynamic>;
  }

  Future<List<dynamic>> fetchNotificaciones() async {
    return await get('/comunicaciones/notificaciones/') as List<dynamic>;
  }

  // ============== MÉTODOS ADICIONALES PARA COMPATIBILIDAD ==============
  Future<List<dynamic>> getGastos() async => fetchGastos();
  Future<List<dynamic>> getReservas() async => fetchReservas();
}
