import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Importa el servicio de API

class AvisosScreen extends StatefulWidget {
  const AvisosScreen({super.key});
  @override
  State<AvisosScreen> createState() => _AvisosScreenState();
}

class _AvisosScreenState extends State<AvisosScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = [];
  final ApiService _apiService = ApiService(); // Instancia del servicio

  @override
  void initState() {
    super.initState();
    _fetchAvisos();
  }

  Future<void> _fetchAvisos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _apiService.fetchAvisos();
      setState(() {
        _items = data;
      });
    } catch (e) {
      setState(() {
        _error = "No se pudieron cargar los avisos. Error: ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _fmt(dynamic v) {
    try {
      final dt = DateTime.tryParse(v?.toString() ?? '');
      if (dt != null) {
        return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
      }
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAvisos),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchAvisos,
                      child: const Text('Reintentar'),
                    )
                  ],
                ),
              ),
            )
          : _items.isEmpty
          ? const Center(child: Text('No hay avisos.'))
          : RefreshIndicator(
            onRefresh: _fetchAvisos,
            child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = (_items[i] as Map?) ?? {};
                  final titulo = (m['titulo'] ?? m['title'] ?? m['asunto'] ?? '')
                      .toString();
                  final cuerpo =
                      (m['mensaje'] ?? m['descripcion'] ?? m['cuerpo'] ?? '')
                          .toString();
                  final fecha = _fmt(
                    m['created_at'] ?? m['fecha'] ?? m['creado'],
                  );
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
                              child: Text(
                                fecha,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
    );
  }
}