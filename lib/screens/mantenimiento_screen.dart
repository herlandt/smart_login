import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MantenimientoScreen extends StatefulWidget {
  const MantenimientoScreen({super.key});

  @override
  State<MantenimientoScreen> createState() => _MantenimientoScreenState();
}

class _MantenimientoScreenState extends State<MantenimientoScreen> {
  List<dynamic>? solicitudes;
  Map<String, dynamic>? perfil;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiService();
      final [perfilRes, solicitudesRes] = await Future.wait([
        api.getPerfilUsuario(),
        api.fetchSolicitudesMantenimiento(),
      ]);
      setState(() {
        perfil = perfilRes as Map<String, dynamic>;
        solicitudes = solicitudesRes as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> cargarSolicitudes() async {
    try {
      final res = await ApiService().fetchSolicitudesMantenimiento();
      setState(() {
        solicitudes = res;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  void mostrarDialogoNuevaSolicitud() {
    String titulo = '';
    String descripcion = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nueva Solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Título'),
              onChanged: (v) => titulo = v,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Descripción'),
              onChanged: (v) => descripcion = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: Text('Crear'),
            onPressed: () async {
              Navigator.pop(ctx);
              await crearSolicitud(titulo, descripcion);
            },
          ),
        ],
      ),
    );
  }

  Future<void> crearSolicitud(String titulo, String descripcion) async {
    if (perfil == null) {
      setState(() {
        error = 'No se pudo obtener información del perfil';
      });
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      // Extraer propiedad_id del perfil
      int? propiedadId;
      if (perfil!['propiedad'] != null) {
        if (perfil!['propiedad'] is Map) {
          propiedadId = perfil!['propiedad']['id'];
        } else if (perfil!['propiedad'] is int) {
          propiedadId = perfil!['propiedad'];
        }
      }

      await ApiService().crearSolicitudMantenimiento({
        'titulo': titulo,
        'descripcion': descripcion,
        'propiedad_id': propiedadId,
      });
      await cargarSolicitudes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mantenimiento')),
      floatingActionButton: FloatingActionButton(
        onPressed: mostrarDialogoNuevaSolicitud,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : solicitudes == null || solicitudes!.isEmpty
          ? const Center(child: Text('No hay solicitudes'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: solicitudes!.length,
              itemBuilder: (ctx, i) {
                final s = solicitudes![i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(s['titulo'] ?? 'Sin título'),
                    subtitle: Text(s['descripcion'] ?? ''),
                    trailing: Text(s['estado'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
