import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('/login/');
    final r = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (r.statusCode == 200) {
      final data = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      final t = (data['token'] as String?)?.trim();
      if (t != null && t.isNotEmpty) {
        await _saveToken(t);
        return true;
      }
    }
    return false;
  }
}
