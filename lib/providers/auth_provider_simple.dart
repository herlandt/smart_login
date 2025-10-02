import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service_actualizado.dart';

/// Proveedor de autenticación actualizado para usar los endpoints correctos del schema OpenAPI 2025
class AuthProviderActualizado with ChangeNotifier {
  // Estado del usuario
  String? _currentUser;
  String? _userRole;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _userProfile;

  // Getters
  String? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get userProfile => _userProfile;

  /// Método de login actualizado con los endpoints correctos
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔐 Intentando login para: $username con API actualizada');

      final apiService = ApiServiceActualizado();
      final loginResponse = await apiService.login(username, password);

      if (loginResponse['token'] != null) {
        _token = loginResponse['token'];
        _currentUser = username;
        _isAuthenticated = true;

        // Obtener perfil del usuario para determinar rol
        try {
          _userProfile = await apiService.getPerfilUsuario();
          _userRole = _determineUserRole(username, _userProfile);
        } catch (e) {
          debugPrint('⚠️ Error al obtener perfil: $e');
          _userRole = _determineUserRole(username, null);
        }

        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('current_user', username);
        await prefs.setString('user_role', _userRole!);
        if (_userProfile != null) {
          await prefs.setString('user_profile', _userProfile.toString());
        }

        debugPrint('✅ Login exitoso para: $username (Rol: $_userRole)');
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Login fallido para: $username - Token no recibido');
        return false;
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      _isAuthenticated = false;
      _currentUser = null;
      _userRole = null;
      _token = null;
      _userProfile = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Determina el rol del usuario basado en las credenciales y perfil
  String _determineUserRole(String username, Map<String, dynamic>? profile) {
    // Primero revisar si el perfil tiene rol definido
    if (profile != null && profile.containsKey('role')) {
      return profile['role'].toString().toUpperCase();
    }

    // Si no, usar mapeo basado en username (compatibilidad)
    switch (username.toLowerCase()) {
      case 'admin':
        return 'PROPIETARIO';
      case 'seguridad1':
      case 'guardia':
        return 'SEGURIDAD';
      case 'mantenimiento1':
      case 'mantenimiento':
        return 'MANTENIMIENTO';
      default:
        return 'RESIDENTE';
    }
  }

  /// Verifica el estado de autenticación al iniciar la app
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final user = prefs.getString('current_user');
      final role = prefs.getString('user_role');

      if (token != null && user != null && role != null) {
        _token = token;
        _currentUser = user;
        _userRole = role;

        // Verificar que el token sigue siendo válido
        try {
          final apiService = ApiServiceActualizado();
          _userProfile = await apiService.getPerfilUsuario();
          _isAuthenticated = true;

          debugPrint('✅ Usuario autenticado: $user (Rol: $role)');
        } catch (e) {
          debugPrint('⚠️ Token expirado o inválido: $e');
          await logout();
        }
      } else {
        debugPrint('ℹ️ No hay sesión guardada');
        await logout();
      }
    } catch (e) {
      debugPrint('❌ Error al verificar estado de auth: $e');
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cierra sesión y limpia los datos
  Future<void> logout() async {
    try {
      final apiService = ApiServiceActualizado();
      await apiService.logout();
    } catch (e) {
      debugPrint('⚠️ Error al hacer logout en el servidor: $e');
    }

    // Limpiar datos locales
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
    await prefs.remove('user_role');
    await prefs.remove('user_profile');

    _isAuthenticated = false;
    _currentUser = null;
    _userRole = null;
    _token = null;
    _userProfile = null;

    debugPrint('👋 Sesión cerrada');
    notifyListeners();
  }

  /// Verifica si el usuario tiene permisos de administrador
  bool get hasAdminPermissions => _userRole == 'PROPIETARIO';

  /// Verifica si el usuario tiene permisos de seguridad
  bool get hasSecurityPermissions =>
      _userRole == 'PROPIETARIO' || _userRole == 'SEGURIDAD';

  /// Verifica si el usuario tiene permisos de mantenimiento
  bool get hasMaintenancePermissions =>
      _userRole == 'PROPIETARIO' || _userRole == 'MANTENIMIENTO';

  /// Verifica permisos específicos
  bool hasPermission(String permission) {
    if (!_isAuthenticated) return false;

    switch (permission.toLowerCase()) {
      case 'admin':
        return hasAdminPermissions;
      case 'security':
        return hasSecurityPermissions;
      case 'maintenance':
        return hasMaintenancePermissions;
      case 'basic':
      default:
        return true; // Todos los usuarios autenticados tienen permisos básicos
    }
  }

  /// Obtiene información del perfil del usuario actualizada
  Future<Map<String, dynamic>?> refreshUserProfile() async {
    if (!_isAuthenticated) return null;

    try {
      final apiService = ApiServiceActualizado();
      _userProfile = await apiService.getPerfilUsuario();

      // Actualizar rol si cambió
      if (_userProfile != null && _userProfile!.containsKey('role')) {
        final newRole = _userProfile!['role'].toString().toUpperCase();
        if (newRole != _userRole) {
          _userRole = newRole;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', _userRole!);
          notifyListeners();
        }
      }

      return _userProfile;
    } catch (e) {
      debugPrint('⚠️ Error al actualizar perfil: $e');
      return null;
    }
  }

  /// Refresca el token de autenticación
  Future<void> refreshToken() async {
    if (!_isAuthenticated) return;

    try {
      // Intentar obtener el perfil para verificar que el token sigue válido
      await refreshUserProfile();
    } catch (e) {
      debugPrint('⚠️ Error al refrescar token: $e');
      await logout();
    }
  }

  /// Obtiene el nombre completo del usuario para mostrar
  String get displayName {
    if (_userProfile != null) {
      final firstName = _userProfile!['first_name'] ?? '';
      final lastName = _userProfile!['last_name'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }

    if (_currentUser == null) return 'Usuario';

    // Fallback a mapeo estático
    switch (_currentUser!.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'residente1':
        return 'Isael Ortiz';
      case 'seguridad1':
        return 'Guardia Seguridad';
      case 'mantenimiento1':
        return 'Personal Mantenimiento';
      case 'invitado1':
        return 'Invitado Carlos';
      case 'propietario1':
        return 'José García';
      case 'inquilino1':
        return 'Ana López';
      default:
        return _currentUser!;
    }
  }

  /// Obtiene la descripción del rol
  String get roleDescription {
    switch (_userRole) {
      case 'PROPIETARIO':
        return 'Acceso completo al sistema';
      case 'RESIDENTE':
        return 'Acceso a servicios residenciales';
      case 'SEGURIDAD':
        return 'Control de acceso y vigilancia';
      case 'MANTENIMIENTO':
        return 'Gestión de mantenimiento';
      default:
        return 'Usuario del sistema';
    }
  }

  /// Verificar conectividad con el backend actualizado
  Future<Map<String, dynamic>> verificarConectividad() async {
    try {
      final apiService = ApiServiceActualizado();
      return await apiService.verificarConectividad();
    } catch (e) {
      return {
        'connected': false,
        'message': 'Error de conectividad: $e',
        'error': e.toString(),
      };
    }
  }

  /// Test específico para emuladores
  Future<Map<String, dynamic>> testConectividadEmulador() async {
    try {
      final apiService = ApiServiceActualizado();
      return await apiService.testConectividadEmulador();
    } catch (e) {
      return {
        'connected': false,
        'message': 'Error en test de conectividad: $e',
        'error': e.toString(),
      };
    }
  }
}
