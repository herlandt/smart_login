/// Configuración de API actualizada basada en el Schema OpenAPI 2025
class ApiConfigActualizada {
  // 🌐 CONFIGURACIÓN DE SERVIDOR
  static const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador Android
  static const String baseUrlLocalhost = 'http://127.0.0.1:8000'; // Alternativa
  static const String baseUrlProduction =
      'https://tu-dominio.com'; // Para producción

  // 🔧 CONFIGURACIÓN DE ENTORNO
  static const String currentEnvironment = 'development';
  static const bool isEmulator = true;
  static const bool isDevelopment = true;

  // ⏱️ TIMEOUTS
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // 📝 HEADERS ESTÁNDAR
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    'User-Agent': 'SmartLogin-Flutter/1.0',
  };

  // 🔐 CONFIGURACIÓN DE AUTENTICACIÓN
  static const String tokenPrefix =
      'Token'; // Prefijo para Authorization header
  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'current_user';
  static const String roleStorageKey = 'user_role';
  static const String profileStorageKey = 'user_profile';

  // 📊 CONFIGURACIÓN DE PAGINACIÓN
  static const int defaultPageSize = 20;
  static const String paginationPageParam = 'page';
  static const String paginationSizeParam = 'page_size';

  // 🔍 FILTROS Y BÚSQUEDA
  static const String searchParam = 'search';
  static const String orderingParam = 'ordering';

  // 🏷️ VERSIÓN DE API
  static const String apiVersion = '1.0.0';
  static const String openApiVersion = '3.0.3';

  // 🛡️ CONFIGURACIÓN DE SEGURIDAD
  static const String securityApiKey =
      'MI_CLAVE_SUPER_SECRETA_12345'; // Para IA endpoints
  static const String securityApiKeyHeader = 'X-API-KEY';

  // 🤖 CONFIGURACIÓN DE IA
  static const String awsRekognitionCollectionId = 'condominio_residentes';

  // 📱 CONFIGURACIÓN ESPECÍFICA PARA EMULADORES
  static const List<String> emulatorTestUrls = [
    'http://10.0.2.2:8000',
    'http://127.0.0.1:8000',
    'http://localhost:8000',
  ];

  // 🎯 MÉTODOS AUXILIARES

  /// Obtiene la URL base según el entorno
  static String getCurrentBaseUrl() {
    switch (currentEnvironment) {
      case 'production':
        return baseUrlProduction;
      case 'development':
      default:
        return isEmulator ? baseUrl : baseUrlLocalhost;
    }
  }

  /// Construye headers con autenticación
  static Map<String, String> getHeadersWithAuth(String? token) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = '$tokenPrefix $token';
    }
    return headers;
  }

  /// Headers para endpoints de IA
  static Map<String, String> getHeadersForIA(String? token) {
    final headers = getHeadersWithAuth(token);
    headers[securityApiKeyHeader] = securityApiKey;
    return headers;
  }

  /// Construye URL completa con parámetros de consulta
  static String buildUrlWithQuery(
    String endpoint,
    Map<String, dynamic>? queryParams,
  ) {
    final baseUrl = getCurrentBaseUrl();
    var url = '$baseUrl$endpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      final validParams = queryParams.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
          )
          .join('&');

      if (validParams.isNotEmpty) {
        url += url.contains('?') ? '&$validParams' : '?$validParams';
      }
    }

    return url;
  }

  /// Configuración específica para debug
  static Map<String, dynamic> getDebugInfo() {
    return {
      'baseUrl': getCurrentBaseUrl(),
      'environment': currentEnvironment,
      'isEmulator': isEmulator,
      'apiVersion': apiVersion,
      'openApiVersion': openApiVersion,
      'headers': defaultHeaders,
      'timeouts': {
        'request': requestTimeout.inSeconds,
        'connection': connectionTimeout.inSeconds,
      },
    };
  }

  /// Valida si una URL es válida para el entorno actual
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Obtiene configuración para diferentes tipos de endpoint
  static Map<String, dynamic> getEndpointConfig(String endpointType) {
    switch (endpointType.toLowerCase()) {
      case 'auth':
        return {
          'requiresAuth': false,
          'timeout': connectionTimeout,
          'retries': 3,
        };
      case 'upload':
        return {
          'requiresAuth': true,
          'timeout': const Duration(minutes: 5),
          'retries': 1,
        };
      case 'ia':
        return {
          'requiresAuth': true,
          'timeout': const Duration(seconds: 45),
          'retries': 2,
          'specialHeaders': {securityApiKeyHeader: securityApiKey},
        };
      default:
        return {'requiresAuth': true, 'timeout': requestTimeout, 'retries': 2};
    }
  }
}

/// Enums para tipos de datos específicos del schema
enum UserRole {
  propietario('PROPIETARIO'),
  residente('RESIDENTE'),
  seguridad('SEGURIDAD'),
  mantenimiento('MANTENIMIENTO');

  const UserRole(this.value);
  final String value;
}

enum RequestStatus {
  abierto('ABIERTO'),
  enProgreso('EN_PROGRESO'),
  resuelto('RESUELTO'),
  cerrado('CERRADO');

  const RequestStatus(this.value);
  final String value;
}

enum PaymentStatus {
  pendiente('PENDIENTE'),
  completado('COMPLETADO'),
  cancelado('CANCELADO');

  const PaymentStatus(this.value);
  final String value;
}

enum EventType {
  ingreso('INGRESO'),
  salida('SALIDA'),
  alerta('ALERTA'),
  incidente('INCIDENTE');

  const EventType(this.value);
  final String value;
}
