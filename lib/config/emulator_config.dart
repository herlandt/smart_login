// Configuración específica para emuladores Android
class EmulatorConfig {
  // ============== DETECCIÓN DE EMULADOR ==============

  /// Verifica si la app está ejecutándose en un emulador
  static Future<bool> isRunningOnEmulator() async {
    try {
      // Por ahora, asumimos que si está en debug mode, podría ser emulador
      return true; // Temporal - siempre true para configuración
    } catch (e) {
      return false;
    }
  }

  // ============== CONFIGURACIÓN DE RED ==============

  /// URLs optimizadas para emuladores
  static const Map<String, String> emulatorUrls = {
    // Para emulador Android: 10.0.2.2 apunta al localhost de la máquina host
    'android_emulator': 'http://10.0.2.2:8000',

    // Para emulador en la misma red
    'network_host': 'http://192.168.0.5:8000',

    // Para testing local
    'localhost': 'http://127.0.0.1:8000',
  };

  /// Obtiene la URL base optimizada para emulador
  static String getOptimizedBaseUrl() {
    // Prioridad: Red local > Emulador Android > Localhost
    return emulatorUrls['network_host']!;
  }

  // ============== CONFIGURACIÓN DE TIMEOUTS ==============

  /// Timeouts optimizados para emuladores (pueden ser más lentos)
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ============== CONFIGURACIÓN DE LOGGING ==============

  /// Nivel de logging para emuladores
  static const bool enableVerboseLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enablePerformanceLogging = true;

  // ============== CONFIGURACIÓN DE UI ==============

  /// Configuraciones específicas para emuladores
  static const Map<String, dynamic> emulatorUIConfig = {
    'enableSlowAnimations': false, // Desactivar animaciones lentas
    'reducedMotion': true, // Reducir movimiento para mejor rendimiento
    'enableDebugging': true, // Activar debugging visual
    'showPerformanceOverlay': false, // Overlay de rendimiento
  };

  // ============== CONFIGURACIÓN DE DATOS DE PRUEBA ==============

  /// Datos específicos para testing en emuladores
  static const Map<String, dynamic> testData = {
    'users': [
      {
        'username': 'emulator_admin',
        'password': 'admin123',
        'role': 'ADMINISTRADOR',
      },
      {
        'username': 'emulator_resident',
        'password': 'resident123',
        'role': 'RESIDENTE',
      },
      {
        'username': 'emulator_security',
        'password': 'security123',
        'role': 'SEGURIDAD',
      },
    ],
    'properties': [
      {'id': 'EMU_001', 'type': 'APARTAMENTO', 'number': '101', 'tower': 'A'},
      {'id': 'EMU_002', 'type': 'APARTAMENTO', 'number': '102', 'tower': 'A'},
    ],
  };

  // ============== MÉTODOS DE UTILIDAD ==============

  /// Configuración de headers optimizados para emuladores
  static Map<String, String> getOptimizedHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'SmartLogin-Emulator/1.0',
      'X-Emulator-Mode': 'true',
      'X-Platform': 'android-emulator',
    };
  }

  /// Configuración de retry policy para emuladores
  static const Map<String, int> retryConfig = {
    'maxRetries': 3,
    'retryDelay': 2000, // milliseconds
    'backoffMultiplier': 2,
  };

  // ============== CONFIGURACIÓN DE PERFORMANCE ==============

  /// Configuraciones para optimizar rendimiento en emuladores
  static const Map<String, dynamic> performanceConfig = {
    'enableCaching': true,
    'cacheSize': 50, // MB
    'enableImageOptimization': true,
    'maxConcurrentRequests': 3,
    'enableGzipCompression': true,
  };

  /// Obtiene la configuración completa para emuladores
  static Map<String, dynamic> getEmulatorConfiguration() {
    return {
      'baseUrl': getOptimizedBaseUrl(),
      'timeouts': {
        'connection': connectionTimeout.inMilliseconds,
        'receive': receiveTimeout.inMilliseconds,
        'send': sendTimeout.inMilliseconds,
      },
      'headers': getOptimizedHeaders(),
      'retry': retryConfig,
      'performance': performanceConfig,
      'ui': emulatorUIConfig,
      'logging': {
        'verbose': enableVerboseLogging,
        'network': enableNetworkLogging,
        'performance': enablePerformanceLogging,
      },
    };
  }
}
