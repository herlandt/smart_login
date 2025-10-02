import 'emulator_config.dart';

// Configuración de URLs para servidor local y emuladores
class ApiConfig {
  // URL del servidor local - PARA DESARROLLO EN PC
  static const String localhost = 'http://127.0.0.1:8000';

  // URL para emulador Android - 10.0.2.2 apunta al host (tu PC)
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  // URL activa - USANDO EMULATOR URL PARA ANDROID
  static String get baseUrl => emulatorUrl;

  // Método para determinar la mejor URL según el entorno
  static String _getOptimalUrl() {
    // Usar localhost para pruebas CORS
    return localhost;
  }

  // Credenciales de prueba
  static const String testUsername = 'residente1';
  static const String testPassword = 'isaelOrtiz2';

  // Roles del sistema según documentación backend
  static const Map<String, String> userRoles = {
    'PROPIETARIO': 'Propietario',
    'RESIDENTE': 'Residente',
    'SEGURIDAD': 'Personal de Seguridad',
    'MANTENIMIENTO': 'Personal de Mantenimiento',
  };

  // Especialidades de mantenimiento
  static const Map<String, String> maintenanceSpecialties = {
    'ELECTRICIDAD': 'Electricidad',
    'PLOMERIA': 'Plomería',
    'JARDINERIA': 'Jardinería',
    'PINTURA': 'Pintura',
    'LIMPIEZA': 'Limpieza',
    'CARPINTERIA': 'Carpintería',
    'AIRES': 'Aire Acondicionado',
    'GENERAL': 'General',
  };

  // Estados de visitas
  static const Map<String, String> visitStates = {
    'PROGRAMADA': 'Programada',
    'EN_CURSO': 'En Curso',
    'FINALIZADA': 'Finalizada',
    'CANCELADA': 'Cancelada',
  };

  // Prioridades de mantenimiento
  static const Map<String, String> maintenancePriorities = {
    'BAJA': 'Baja',
    'MEDIA': 'Media',
    'ALTA': 'Alta',
    'URGENTE': 'Urgente',
  };

  // Estados de pago
  static const Map<String, String> paymentStates = {
    'PENDIENTE': 'Pendiente',
    'COMPLETADO': 'Completado',
    'FALLIDO': 'Fallido',
  };

  // Estados de solicitudes de mantenimiento
  static const Map<String, String> maintenanceStates = {
    'PENDIENTE': 'Pendiente',
    'EN_PROGRESO': 'En Progreso',
    'COMPLETADA': 'Completada',
    'CERRADA': 'Cerrada',
  };

  // Información de configuración
  static String get currentEnvironment {
    return 'Emulador Android Optimizado';
  }

  static bool get isLocal => true;
  static bool get isEmulator => true;

  // Configuración específica para troubleshooting
  static Map<String, String> get troubleshootingInfo => {
    'current_url': baseUrl,
    'environment': currentEnvironment,
    'emulator_note':
        'Si 10.0.2.2 falla, servidor Django debe escuchar en 0.0.0.0:8000',
    'server_command': 'python manage.py runserver 0.0.0.0:8000',
    'firewall_note': 'Verificar que Windows Firewall no bloquee puerto 8000',
    'backend_version': '2.0 - 30/Sep/2025',
    'features': 'Roles, Estados, Filtros Avanzados, Documentación Automática',
  };

  // Verificar si un rol tiene permisos específicos
  static bool hasPermission(String userRole, String module) {
    switch (userRole) {
      case 'PROPIETARIO':
        return true; // Admin total
      case 'RESIDENTE':
        return [
          'condominio',
          'finanzas',
          'perfil',
          'mantenimiento',
        ].contains(module);
      case 'SEGURIDAD':
        return ['seguridad', 'perfil'].contains(module);
      case 'MANTENIMIENTO':
        return ['mantenimiento', 'perfil'].contains(module);
      default:
        return false;
    }
  }

  // Endpoints públicos que no requieren autenticación
  static const List<String> publicEndpoints = [
    '/',
    '/login/',
    '/registro/',
    '/schema/swagger-ui/',
    '/schema/redoc/',
    '/schema/',
  ];
}
