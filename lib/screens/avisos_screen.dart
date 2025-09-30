import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});
  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  static const String base =
      'https://smart-condominium-backend-cg7l.onrender.com/api';

  // 1º intenta la ruta correcta de condominio; si cambia el prefijo, probamos otras.
  final List<String> _candidatos = const [
    '/condominio/avisos/',
    '/avisos/',
    '/notificaciones/avisos/',
  ];

  bool _loading = false;
  String? _error;
  String? _usado;            // para mostrar qué ruta funcionó
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchAvisos();
  }

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchAvisos() async {
    setState(() { _loading = true; _error = null; _usado = null; });

    final t = await _token();
    if (t == null || t.isEmpty) {
      setState(() { _error = 'No hay token. Inicia sesión.'; _loading = false; });
      return;
    }

    Exception? lastErr;
    for (final ep in _candidatos) {
      final uri = Uri.parse('${base.replaceAll(RegExp(r"/$"), "")}'
          '${ep.startsWith("/") ? ep : "/$ep"}');

      try {
        final r = await http.get(uri, headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $t',
        });

        if (r.statusCode == 200) {
          final data = jsonDecode(utf8.decode(r.bodyBytes));
          final list = data is List ? data : (data['results'] ?? []);
          setState(() {
            _items = List<dynamic>.from(list as Iterable);
            _usado = ep;
            _loading = false;
          });
          return; // éxito
        } else {
          lastErr = Exception('HTTP ${r.statusCode} ${uri}\n${r.body}');
        }
      } catch (e) {
        lastErr = Exception('$e');
      }
    }

    setState(() {
      _error = lastErr?.toString() ?? 'No se pudo obtener avisos.';
      _loading = false;
    });
  }

  String _fmt(dynamic v) {
    try {
      final dt = DateTime.tryParse(v?.toString() ?? '');
      if (dt != null) return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
      return v?.toString() ?? '';
    } catch (_) {
      return v?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          if (_usado != null)
            Center(child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(_usado!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            )),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAvisos),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(_error!, style: const TextStyle(color: Colors.red)),
                )
              : _items.isEmpty
                  ? const Center(child: Text('No hay avisos.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final m = (_items[i] as Map?) ?? {};
                        final titulo = (m['titulo'] ?? m['title'] ?? m['asunto'] ?? '').toString();
                        final cuerpo = (m['mensaje'] ?? m['descripcion'] ?? m['cuerpo'] ?? '').toString();
                        final fecha = _fmt(m['created_at'] ?? m['fecha'] ?? m['creado']);
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.campaign),
                            title: Text(titulo.isEmpty ? '(sin título)' : titulo),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cuerpo.isNotEmpty) Text(cuerpo),
                                if (fecha.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(fecha, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
