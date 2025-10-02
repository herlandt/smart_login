import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complete_models.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Método de login actualizado
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final loginResponse = await ApiService.login(username, password);

      if (loginResponse != null) {
        _currentUser = loginResponse.user;
        _isAuthenticated = true;

        // Guardar información del usuario
        await _saveUserData();

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error en login: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Verificar el estado de autenticación al iniciar la app
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Cargar datos del usuario desde storage
      await _loadUserData();

      if (_currentUser != null) {
        // Verificar que el token siga siendo válido
        final authStatus = await ApiService.checkAuthStatus();

        if (authStatus != null && authStatus.isAuthenticated) {
          _isAuthenticated = true;
        } else {
          // Token inválido, limpiar datos
          await logout();
        }
      }
    } catch (e) {
      print('Error verificando auth status: $e');
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;

    // Limpiar el token del ApiService
    await ApiService.logout();

    // Limpiar datos locales
    await _clearUserData();

    notifyListeners();
  }

  // Guardar datos del usuario localmente
  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser!.id.toString());
      await prefs.setString('user_username', _currentUser!.username);
      await prefs.setString('user_email', _currentUser!.email);
      await prefs.setBool('user_is_staff', _currentUser!.isStaff);
      await prefs.setBool('is_authenticated', true);
    }
  }

  // Cargar datos del usuario desde storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool('is_authenticated') ?? false;

    if (isAuth) {
      final userId = prefs.getString('user_id');
      final username = prefs.getString('user_username');
      final email = prefs.getString('user_email');
      final isStaff = prefs.getBool('user_is_staff') ?? false;

      if (userId != null && username != null && email != null) {
        // Recrear un objeto User básico
        _currentUser = User(
          id: int.parse(userId),
          username: username,
          email: email,
          isStaff: isStaff,
        );
        _isAuthenticated = true;
      }
    }
  }

  // Limpiar datos del usuario
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_email');
    await prefs.remove('user_is_staff');
    await prefs.remove('is_authenticated');
    await prefs.remove('auth_token');
  }

  // Actualizar información del usuario
  Future<void> updateUserProfile() async {
    if (!_isAuthenticated) return;

    try {
      // Llamar al endpoint de perfil para obtener datos actualizados
      final authStatus = await ApiService.checkAuthStatus();

      if (authStatus != null && authStatus.isAuthenticated) {
        // Aquí podrías hacer una llamada adicional para obtener datos completos del usuario
        // Por ahora solo actualizamos el estado
        notifyListeners();
      }
    } catch (e) {
      print('Error actualizando perfil: $e');
    }
  }

  // Verificar si el usuario tiene un rol específico (basado en isStaff)
  bool hasRole(String role) {
    if (_currentUser == null) return false;

    // Por ahora, usamos isStaff para determinar si es administrador
    switch (role.toLowerCase()) {
      case 'administrador':
      case 'admin':
        return _currentUser!.isStaff;
      case 'residente':
        return !_currentUser!.isStaff;
      default:
        return false;
    }
  }

  // Verificar si es administrador
  bool get isAdmin => _currentUser?.isStaff ?? false;

  // Verificar si es residente
  bool get isResident => !(_currentUser?.isStaff ?? true);

  // Verificar si es personal de seguridad
  bool get isSecurity => hasRole('seguridad');

  // Verificar si es personal de mantenimiento
  bool get isMaintenance => hasRole('mantenimiento');

  // Método de compatibilidad con el AuthProvider anterior
  bool get isAuth => _isAuthenticated;

  // Método de compatibilidad para restaurar sesión
  Future<void> tryRestoreSession() async {
    await checkAuthStatus();
  }
}
