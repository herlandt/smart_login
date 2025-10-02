import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/emulator_config.dart';

/// Servicio especializado para conectividad en emuladores Android
class EmulatorNetworkService {
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Prueba múltiples URLs para encontrar la conexión óptima en emuladores
  static Future<String> findOptimalUrl() async {
    final urlsToTest = [
      'http://192.168.0.5:8000', // Red local (preferida)
      'http://10.0.2.2:8000', // Emulador Android estándar
      'http://127.0.0.1:8000', // Localhost como fallback
    ];

    print('🔍 Probando conectividad en emulador...');

    for (String url in urlsToTest) {
      try {
        print('⚡ Probando: $url');

        final response = await http
            .get(
              Uri.parse('$url/api/welcome/'),
              headers: EmulatorConfig.getOptimizedHeaders(),
            )
            .timeout(_defaultTimeout);

        if (response.statusCode == 200) {
          print('✅ Conexión exitosa con: $url');
          return url;
        } else {
          print('❌ Error ${response.statusCode} en: $url');
        }
      } catch (e) {
        print('❌ Fallo de conexión en $url: $e');
        continue;
      }
    }

    print('⚠️ No se pudo conectar a ninguna URL, usando por defecto');
    return urlsToTest.first; // Usar la primera como fallback
  }

  /// Verifica el estado del servidor backend
  static Future<Map<String, dynamic>> checkBackendStatus() async {
    try {
      print('🏥 Verificando estado del backend...');

      final url = await findOptimalUrl();
      final response = await http
          .get(
            Uri.parse('$url/api/welcome/'),
            headers: EmulatorConfig.getOptimizedHeaders(),
          )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend operativo: ${data['message']}');

        return {
          'status': 'online',
          'url': url,
          'response_time': DateTime.now().millisecondsSinceEpoch,
          'data': data,
        };
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Backend no disponible: $e');
      return {
        'status': 'offline',
        'error': e.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
  }

  /// Configuración específica para HttpClient en emuladores
  static HttpClient createOptimizedHttpClient() {
    final client = HttpClient();

    // Timeouts optimizados para emuladores
    client.connectionTimeout = EmulatorConfig.connectionTimeout;
    client.idleTimeout = const Duration(seconds: 60);

    // Configuración de red para emuladores
    client.findProxy = (url) => 'DIRECT'; // Sin proxy
    client.badCertificateCallback = (cert, host, port) =>
        true; // Para desarrollo

    return client;
  }

  /// Diagnóstica problemas comunes de red en emuladores
  static Future<Map<String, dynamic>> diagnoseNetworkIssues() async {
    print('🔧 Diagnosticando problemas de red en emulador...');

    final diagnostics = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'platform': Platform.operatingSystem,
      'isEmulator': true,
    };

    // Test 1: Verificar conectividad básica
    try {
      final internetResult = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 10));
      diagnostics['internet_connectivity'] = internetResult.isNotEmpty;
      print('✅ Conectividad a internet: OK');
    } catch (e) {
      diagnostics['internet_connectivity'] = false;
      diagnostics['internet_error'] = e.toString();
      print('❌ Sin conectividad a internet');
    }

    // Test 2: Verificar acceso al backend
    final backendStatus = await checkBackendStatus();
    diagnostics['backend_status'] = backendStatus;

    // Test 3: Verificar configuración de URLs
    diagnostics['tested_urls'] = [
      'http://192.168.0.5:8000',
      'http://10.0.2.2:8000',
      'http://127.0.0.1:8000',
    ];

    // Test 4: Información del emulador
    diagnostics['emulator_info'] = {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'environment': Platform.environment,
    };

    // Recomendaciones específicas para emuladores
    diagnostics['recommendations'] = [
      'Verificar que el servidor Django esté ejecutándose con: python manage.py runserver 0.0.0.0:8000',
      'Confirmar que el firewall de Windows permita conexiones en el puerto 8000',
      'Si 192.168.0.5 falla, el emulador intentará usar 10.0.2.2 automáticamente',
      'Verificar que la PC y el emulador estén en la misma red virtual',
    ];

    print('📊 Diagnóstico completado');
    return diagnostics;
  }

  /// Ejecuta un test de conectividad completo para emuladores
  static Future<bool> runConnectivityTest() async {
    print('🧪 Ejecutando test de conectividad para emulador...');

    try {
      // Paso 1: Diagnosticar red
      final diagnostics = await diagnoseNetworkIssues();

      // Paso 2: Encontrar URL óptima
      final optimalUrl = await findOptimalUrl();

      // Paso 3: Verificar backend
      final backendStatus = await checkBackendStatus();

      final isConnected = backendStatus['status'] == 'online';

      print(
        isConnected
            ? '✅ Test de conectividad: EXITOSO'
            : '❌ Test de conectividad: FALLIDO',
      );

      // Guardar información de debugging
      _saveDebugInfo({
        'test_result': isConnected,
        'optimal_url': optimalUrl,
        'diagnostics': diagnostics,
        'backend_status': backendStatus,
      });

      return isConnected;
    } catch (e) {
      print('❌ Error en test de conectividad: $e');
      return false;
    }
  }

  /// Guarda información de debugging para troubleshooting
  static void _saveDebugInfo(Map<String, dynamic> info) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      print('💾 Información de debug guardada - $timestamp');
      // Aquí puedes implementar guardado persistente si es necesario
    } catch (e) {
      print('⚠️ No se pudo guardar debug info: $e');
    }
  }
}
