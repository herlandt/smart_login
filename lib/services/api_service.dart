import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'endpoints.dart';

class ApiService {
  ApiService();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
    if (withAuth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Token $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('${Endpoints.base}${Endpoints.login}');
    final res = await http.post(
      uri,
      headers: await _headers(withAuth: false),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login ${res.statusCode}: ${res.body}');
  }

  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${Endpoints.base}$endpoint');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw Exception('GET $endpoint → ${res.statusCode}\n${res.body}');
  }
}
