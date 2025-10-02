import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'endpoints_actualizados.dart';

/// Servicio de API actualizado para coincidir con el schema OpenAPI 2025
class ApiServiceActualizado {
  // URL base del servidor
  String get baseUrl => ApiConfig.baseUrl;

  // ============== GESTIÓN DE TOKENS ==============

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> _getToken() async {
    return await getStoredToken();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ============== HEADERS ==============

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'User-Agent': 'SmartLogin-Flutter/1.0',
    };

    if (withAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Token $token';
        debugPrint('🔑 Token enviado en headers: Token ${token.substring(0, 10)}...');
      } else {
        debugPrint('⚠️ No hay token disponible para autenticación');
      }
    }
    return headers;
  }

  // ============== MÉTODOS HTTP GENÉRICOS ==============

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    try {
      // Construir URL con query parameters
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // Obtener headers
      final headers = await _headers(withAuth: withAuth);

      // Realizar request
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      // Procesar respuesta
      debugPrint('📡 ${method.toUpperCase()} $url - Status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          return {'success': true, 'data': response.body};
        }
      } else {
        debugPrint('❌ Error ${response.statusCode}: ${response.body}');
        throw ApiException(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      debugPrint('Error en _makeRequest: $e');
      rethrow;
    }
  }

  // ============== AUTENTICACIÓN ==============

  /// Login con el endpoint correcto de tu schema
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = '${baseUrl}${EndpointsActualizados.login}';

    debugPrint('🔐 Intentando login para: $username en $url');

    final response = await _makeRequest(
      'POST',
      url,
      body: {'username': username, 'password': password},
      withAuth: false,
    );

    // Guardar token si está presente
    if (response['token'] != null) {
      final token = response['token'] as String;
      await _saveToken(token);
      debugPrint('✅ Token guardado exitosamente: ${token.substring(0, 10)}...');
    } else {
      debugPrint('⚠️ No se recibió token en la respuesta de login');
    }

    return response;
  }

  /// Logout - Solo limpia localmente ya que el backend no tiene endpoint de logout
  Future<void> logout() async {
    try {
      debugPrint('👋 Cerrando sesión localmente');
      await _removeToken();
      debugPrint('✅ Token eliminado exitosamente');
    } catch (e) {
      debugPrint('❌ Error al limpiar token local: $e');
      // Asegurar que se elimine el token incluso si hay error
      await _removeToken();
    }
  }

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>> getPerfilUsuario() async {
    final url = '${baseUrl}${EndpointsActualizados.usuariosPerfil}';
    return await _makeRequest('GET', url);
  }

  /// Registrar nuevo usuario
  Future<Map<String, dynamic>> registrarUsuario(
    Map<String, dynamic> userData,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.registro}';
    return await _makeRequest('POST', url, body: userData, withAuth: false);
  }

  // ============== CONDOMINIOS ==============

  /// Obtener avisos del condominio
  Future<List<dynamic>> getAvisos({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.condominioAvisos}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Crear nuevo aviso
  Future<Map<String, dynamic>> crearAviso(
    Map<String, dynamic> avisoData,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.condominioAvisos}';
    return await _makeRequest('POST', url, body: avisoData);
  }

  /// Obtener propiedades
  Future<List<dynamic>> getPropiedades({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.condominioPropiedades}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Obtener reglas del condominio (solo lectura)
  Future<List<dynamic>> getReglas({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.condominioReglas}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Obtener áreas comunes
  Future<List<dynamic>> getAreasComunes({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.condominioAreasComunes}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  // ============== FINANZAS ==============

  /// Obtener gastos
  Future<List<dynamic>> getGastos({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.finanzasGastos}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Crear nuevo gasto
  Future<Map<String, dynamic>> crearGasto(
    Map<String, dynamic> gastoData,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.finanzasGastos}';
    return await _makeRequest('POST', url, body: gastoData);
  }

  /// Registrar pago para un gasto
  Future<Map<String, dynamic>> registrarPagoGasto(
    int gastoId,
    Map<String, dynamic> pagoData,
  ) async {
    final url = EndpointsActualizados.gastoRegistrarPago(gastoId);
    return await _makeRequest('POST', '${baseUrl}$url', body: pagoData);
  }

  /// Obtener pagos
  Future<List<dynamic>> getPagos({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.finanzasPagos}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Obtener estado de cuenta del usuario
  Future<Map<String, dynamic>> getEstadoCuenta() async {
    final url = '${baseUrl}${EndpointsActualizados.finanzasEstadoCuenta}';
    return await _makeRequest('GET', url);
  }

  /// Obtener reporte resumen financiero
  Future<Map<String, dynamic>> getReporteResumen() async {
    final url = '${baseUrl}${EndpointsActualizados.finanzasReporteResumen}';
    return await _makeRequest('GET', url);
  }

  // ============== SEGURIDAD ==============

  /// Obtener visitantes
  Future<List<dynamic>> getVisitantes({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitantes}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Registrar nuevo visitante
  Future<Map<String, dynamic>> registrarVisitante(
    Map<String, dynamic> visitanteData,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitantes}';
    return await _makeRequest('POST', url, body: visitanteData);
  }

  /// Obtener visitas
  Future<List<dynamic>> getVisitas({Map<String, String>? filtros}) async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitas}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Obtener visitas abiertas (sin cerrar)
  Future<List<dynamic>> getVisitasAbiertas() async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitasAbiertas}';
    final response = await _makeRequest('GET', url);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Crear nueva visita
  Future<Map<String, dynamic>> crearVisita(
    Map<String, dynamic> datosVisita,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitas}';
    return await _makeRequest('POST', url, body: datosVisita);
  }

  /// Crear nuevo visitante
  Future<Map<String, dynamic>> crearVisitante(
    Map<String, dynamic> datosVisitante,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadVisitantes}';
    return await _makeRequest('POST', url, body: datosVisitante);
  }

  /// Obtener dashboard de seguridad - resumen
  Future<Map<String, dynamic>> getDashboardSeguridadResumen() async {
    final url = '${baseUrl}${EndpointsActualizados.seguridadDashboardResumen}';
    return await _makeRequest('GET', url);
  }

  /// Control de acceso vehicular
  Future<Map<String, dynamic>> controlAccesoVehicular(
    Map<String, dynamic> data,
  ) async {
    final url =
        '${baseUrl}${EndpointsActualizados.seguridadControlAccesoVehicular}';
    return await _makeRequest('POST', url, body: data);
  }

  // ============== MANTENIMIENTO ==============

  /// Obtener solicitudes de mantenimiento
  Future<List<dynamic>> getSolicitudesMantenimiento({
    Map<String, String>? filtros,
  }) async {
    final url = '${baseUrl}${EndpointsActualizados.mantenimientoSolicitudes}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  /// Crear solicitud de mantenimiento
  Future<Map<String, dynamic>> crearSolicitudMantenimiento(
    Map<String, dynamic> solicitudData,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.mantenimientoSolicitudes}';
    return await _makeRequest('POST', url, body: solicitudData);
  }

  /// Asignar solicitud de mantenimiento
  Future<Map<String, dynamic>> asignarSolicitudMantenimiento(
    int solicitudId,
    Map<String, dynamic> data,
  ) async {
    final url = EndpointsActualizados.mantenimientoAsignar(solicitudId);
    return await _makeRequest('POST', '${baseUrl}$url', body: data);
  }

  /// Cambiar estado de solicitud de mantenimiento
  Future<Map<String, dynamic>> cambiarEstadoSolicitud(
    int solicitudId,
    Map<String, dynamic> data,
  ) async {
    final url = EndpointsActualizados.mantenimientoCambiarEstado(solicitudId);
    return await _makeRequest('POST', '${baseUrl}$url', body: data);
  }

  // ============== NOTIFICACIONES ==============

  /// Registrar dispositivo para notificaciones
  Future<Map<String, dynamic>> registrarDispositivo(
    Map<String, dynamic> dispositivoData,
  ) async {
    final url =
        '${baseUrl}${EndpointsActualizados.notificacionesRegistrarDispositivo}';
    return await _makeRequest('POST', url, body: dispositivoData);
  }

  /// Enviar notificación demo
  Future<Map<String, dynamic>> enviarNotificacionDemo(
    Map<String, dynamic> data,
  ) async {
    final url = '${baseUrl}${EndpointsActualizados.notificacionesDemo}';
    return await _makeRequest('POST', url, body: data);
  }

  // ============== AUDITORÍA ==============

  /// Obtener bitácora de auditoría (solo administradores)
  Future<List<dynamic>> getBitacoraAuditoria({
    Map<String, String>? filtros,
  }) async {
    final url = '${baseUrl}${EndpointsActualizados.auditoriaBitacora}';
    final response = await _makeRequest('GET', url, queryParams: filtros);
    return response['results'] ?? response['data'] ?? [];
  }

  // ============== VERIFICACIÓN DE CONECTIVIDAD ==============

  /// Verificar conectividad con el backend
  Future<Map<String, dynamic>> verificarConectividad() async {
    try {
      final url = '${baseUrl}${EndpointsActualizados.api}';
      final response = await _makeRequest('GET', url, withAuth: false);
      return {
        'connected': true,
        'message': 'Conectado exitosamente',
        'data': response,
      };
    } catch (e) {
      return {
        'connected': false,
        'message': 'Error de conectividad: $e',
        'error': e.toString(),
      };
    }
  }

  /// Test de conectividad específico para emuladores
  Future<Map<String, dynamic>> testConectividadEmulador() async {
    final List<String> urlsToTest = [
      'http://10.0.2.2:8000/api/',
      'http://127.0.0.1:8000/api/',
      'http://localhost:8000/api/',
    ];

    for (String testUrl in urlsToTest) {
      try {
        final response = await http
            .get(
              Uri.parse(testUrl),
              headers: {'User-Agent': 'SmartLogin-ConnectivityTest/1.0'},
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          return {
            'connected': true,
            'url': testUrl,
            'message': 'Conectado exitosamente',
            'statusCode': response.statusCode,
          };
        }
      } catch (e) {
        debugPrint('Error probando $testUrl: $e');
        continue;
      }
    }

    return {
      'connected': false,
      'message': 'No se pudo conectar a ninguna URL de test',
      'testedUrls': urlsToTest,
    };
  }
}

/// Excepción personalizada para errores de API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  const ApiException(this.message, this.statusCode, this.responseBody);

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}
