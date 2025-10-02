import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';
import '../services/api_service_actualizado.dart';

/// Pantalla de gestión de avisos - Permite ver y crear avisos
class AvisosManagementScreen extends StatefulWidget {
  const AvisosManagementScreen({super.key});

  @override
  State<AvisosManagementScreen> createState() => _AvisosManagementScreenState();
}

class _AvisosManagementScreenState extends State<AvisosManagementScreen> {
  final ApiServiceActualizado _apiService = ApiServiceActualizado();
  List<dynamic> _avisos = [];
  bool _isLoading = true;
  bool _isCreating = false;

  // Controladores para crear aviso
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  String _prioridad = 'NORMAL';

  @override
  void initState() {
    super.initState();
    _cargarAvisos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _cargarAvisos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final avisos = await _apiService.getAvisos();
      setState(() {
        _avisos = avisos;
      });
    } catch (e) {
      debugPrint('Error cargando avisos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando avisos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _crearAviso() async {
    if (_tituloController.text.trim().isEmpty ||
        _contenidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final datosAviso = {
        'titulo': _tituloController.text.trim(),
        'contenido': _contenidoController.text.trim(),
        'prioridad': _prioridad,
        'activo': true,
      };

      await _apiService.crearAviso(datosAviso);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Aviso creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _tituloController.clear();
        _contenidoController.clear();
        _prioridad = 'NORMAL';

        // Recargar avisos
        _cargarAvisos();

        // Cerrar modal
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error creando aviso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creando aviso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderActualizado>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Gestión de Avisos'),
            backgroundColor: Colors.orange[700],
            foregroundColor: Colors.white,
            actions: [
              // Solo mostrar botón crear si es administrador
              if (authProvider.hasAdminPermissions)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Crear Aviso',
                  onPressed: () => _mostrarDialogoCrearAviso(),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _cargarAvisos,
                  child: _avisos.isEmpty
                      ? _buildEstadoVacio()
                      : _buildListaAvisos(),
                ),
        );
      },
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay avisos disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los avisos del condominio aparecerán aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildListaAvisos() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _avisos.length,
      itemBuilder: (context, index) {
        final aviso = _avisos[index];
        return _buildTarjetaAviso(aviso);
      },
    );
  }

  Widget _buildTarjetaAviso(Map<String, dynamic> aviso) {
    final prioridad = aviso['prioridad'] ?? 'NORMAL';
    final Color colorPrioridad = _getColorPrioridad(prioridad);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con título y prioridad
            Row(
              children: [
                Expanded(
                  child: Text(
                    aviso['titulo'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrioridad.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorPrioridad),
                  ),
                  child: Text(
                    prioridad,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorPrioridad,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contenido
            Text(
              aviso['contenido'] ?? 'Sin contenido',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Footer con fecha
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatearFecha(aviso['fecha_creacion']),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                if (aviso['activo'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorPrioridad(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'ALTA':
      case 'URGENTE':
        return Colors.red;
      case 'MEDIA':
        return Colors.orange;
      case 'BAJA':
      case 'NORMAL':
      default:
        return Colors.blue;
    }
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Fecha desconocida';

    try {
      final DateTime fechaObj = DateTime.parse(fecha.toString());
      return '${fechaObj.day}/${fechaObj.month}/${fechaObj.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _mostrarDialogoCrearAviso() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Crear Nuevo Aviso'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título del Aviso',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 100,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contenidoController,
                      decoration: const InputDecoration(
                        labelText: 'Contenido del Aviso',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _prioridad,
                      decoration: const InputDecoration(
                        labelText: 'Prioridad',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'BAJA', child: Text('Baja')),
                        DropdownMenuItem(
                          value: 'NORMAL',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'MEDIA', child: Text('Media')),
                        DropdownMenuItem(value: 'ALTA', child: Text('Alta')),
                        DropdownMenuItem(
                          value: 'URGENTE',
                          child: Text('Urgente'),
                        ),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          _prioridad = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _isCreating ? null : _crearAviso,
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear Aviso'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
