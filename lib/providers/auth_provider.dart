import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api;
  AuthProvider(this._api);

  bool _isAuth = false;
  bool get isAuth => _isAuth;

  Future<void> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    _isAuth = t != null && t.isNotEmpty;
    notifyListeners();
  }

  Future<bool> login(String user, String pass) async {
    final ok = await _api.login(user.trim(), pass);
    _isAuth = ok;
    notifyListeners();
    return ok;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _isAuth = false;
    notifyListeners();
  }
}
