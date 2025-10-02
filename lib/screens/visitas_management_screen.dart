import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';
import '../services/api_service_actualizado.dart';

/// Pantalla de gestión de visitas - Permite ver y crear visitas
class VisitasManagementScreen extends StatefulWidget {
  const VisitasManagementScreen({super.key});

  @override
  State<VisitasManagementScreen> createState() =>
      _VisitasManagementScreenState();
}

class _VisitasManagementScreenState extends State<VisitasManagementScreen>
    with TickerProviderStateMixin {
  final ApiServiceActualizado _apiService = ApiServiceActualizado();
  late TabController _tabController;

  // Estados
  List<dynamic> _visitas = [];
  List<dynamic> _visitantes = [];
  bool _isLoading = true;
  bool _isCreating = false;

  // Controladores para crear visita
  final _nombreVisitanteController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _propiedadController = TextEditingController();
  String _tipoDocumento = 'CI';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreVisitanteController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _motivoController.dispose();
    _propiedadController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final futures = await Future.wait([
        _apiService.getVisitas(),
        _apiService.getVisitantes(),
      ]);

      setState(() {
        _visitas = futures[0];
        _visitantes = futures[1];
      });
    } catch (e) {
      debugPrint('Error cargando datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando datos: $e'),
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

  Future<void> _crearVisita() async {
    if (_nombreVisitanteController.text.trim().isEmpty ||
        _documentoController.text.trim().isEmpty ||
        _propiedadController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Primero crear el visitante si no existe
      final datosVisitante = {
        'nombre_completo': _nombreVisitanteController.text.trim(),
        'tipo_documento': _tipoDocumento,
        'numero_documento': _documentoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      };

      await _apiService.crearVisitante(datosVisitante);

      // Luego crear la visita
      final datosVisita = {
        'visitante': {
          'nombre_completo': _nombreVisitanteController.text.trim(),
          'numero_documento': _documentoController.text.trim(),
        },
        'propiedad': _propiedadController.text.trim(),
        'motivo_visita': _motivoController.text.trim(),
        'estado': 'PENDIENTE',
        'fecha_visita': DateTime.now().toIso8601String(),
      };

      await _apiService.crearVisita(datosVisita);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Visita registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _nombreVisitanteController.clear();
        _documentoController.clear();
        _telefonoController.clear();
        _motivoController.clear();
        _propiedadController.clear();
        _tipoDocumento = 'CI';

        // Recargar datos
        _cargarDatos();

        // Cerrar modal
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error creando visita: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error registrando visita: $e'),
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
            title: const Text('Gestión de Visitas'),
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Visitas', icon: Icon(Icons.people)),
                Tab(text: 'Visitantes', icon: Icon(Icons.person)),
              ],
            ),
            actions: [
              // Solo mostrar botón crear si es seguridad o admin
              if (authProvider.hasSecurityPermissions ||
                  authProvider.hasAdminPermissions)
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Registrar Visita',
                  onPressed: () => _mostrarDialogoCrearVisita(),
                ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _buildTabVisitas(),
                    ),
                    RefreshIndicator(
                      onRefresh: _cargarDatos,
                      child: _buildTabVisitantes(),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTabVisitas() {
    if (_visitas.isEmpty) {
      return _buildEstadoVacio(
        icon: Icons.people_outline,
        titulo: 'No hay visitas registradas',
        subtitulo: 'Las visitas registradas aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visitas.length,
      itemBuilder: (context, index) {
        final visita = _visitas[index];
        return _buildTarjetaVisita(visita);
      },
    );
  }

  Widget _buildTabVisitantes() {
    if (_visitantes.isEmpty) {
      return _buildEstadoVacio(
        icon: Icons.person_outline,
        titulo: 'No hay visitantes registrados',
        subtitulo: 'Los visitantes registrados aparecerán aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visitantes.length,
      itemBuilder: (context, index) {
        final visitante = _visitantes[index];
        return _buildTarjetaVisitante(visitante);
      },
    );
  }

  Widget _buildEstadoVacio({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaVisita(Map<String, dynamic> visita) {
    final estado = visita['estado'] ?? 'DESCONOCIDO';
    final Color colorEstado = _getColorEstado(estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getNombreVisitante(visita),
                    style: const TextStyle(
                      fontSize: 16,
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
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorEstado),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorEstado,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información de la visita
            _buildInfoRow(
              Icons.home,
              'Propiedad',
              visita['propiedad'] ?? 'No especificada',
            ),
            if (visita['motivo_visita'] != null)
              _buildInfoRow(
                Icons.description,
                'Motivo',
                visita['motivo_visita'],
              ),
            _buildInfoRow(
              Icons.access_time,
              'Fecha',
              _formatearFecha(visita['fecha_visita']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaVisitante(Map<String, dynamic> visitante) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitante['nombre_completo'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${visitante['tipo_documento'] ?? 'CI'}: ${visitante['numero_documento'] ?? 'Sin documento'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Información del visitante
            if (visitante['telefono'] != null)
              _buildInfoRow(Icons.phone, 'Teléfono', visitante['telefono']),
            _buildInfoRow(
              Icons.access_time,
              'Registrado',
              _formatearFecha(visitante['fecha_registro']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'AUTORIZADA':
      case 'COMPLETADA':
        return Colors.green;
      case 'PENDIENTE':
        return Colors.orange;
      case 'RECHAZADA':
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getNombreVisitante(Map<String, dynamic> visita) {
    if (visita['visitante'] != null &&
        visita['visitante']['nombre_completo'] != null) {
      return visita['visitante']['nombre_completo'];
    }
    return visita['nombre_visitante'] ?? 'Visitante sin nombre';
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'Fecha desconocida';

    try {
      final DateTime fechaObj = DateTime.parse(fecha.toString());
      return '${fechaObj.day}/${fechaObj.month}/${fechaObj.year} ${fechaObj.hour.toString().padLeft(2, '0')}:${fechaObj.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  void _mostrarDialogoCrearVisita() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Registrar Nueva Visita'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nombreVisitanteController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: _tipoDocumento,
                            decoration: const InputDecoration(
                              labelText: 'Tipo Doc.',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'CI', child: Text('CI')),
                              DropdownMenuItem(
                                value: 'PASAPORTE',
                                child: Text('Pasaporte'),
                              ),
                              DropdownMenuItem(
                                value: 'EXTRANJERO',
                                child: Text('Extranjero'),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                _tipoDocumento = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _documentoController,
                            decoration: const InputDecoration(
                              labelText: 'Número Documento *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _propiedadController,
                      decoration: const InputDecoration(
                        labelText: 'Propiedad a Visitar *',
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Apt 101, Casa 15',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _motivoController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de la Visita',
                        border: OutlineInputBorder(),
                        hintText: 'Personal, Trabajo, Delivery, etc.',
                      ),
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
                  onPressed: _isCreating ? null : _crearVisita,
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
