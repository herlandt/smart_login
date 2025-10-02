import 'package:flutter/material.dart';
import '../services/api_service_actualizado.dart';

class CondominioScreen extends StatefulWidget {
  const CondominioScreen({super.key});

  @override
  State<CondominioScreen> createState() => _CondominioScreenState();
}

class _CondominioScreenState extends State<CondominioScreen> {
  List<dynamic>? propiedades;
  List<dynamic>? areasComunes;
  List<dynamic>? avisos;
  List<dynamic>? reglas;
  List<dynamic>? reservas;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarCondominio();
  }

  Future<void> cargarCondominio() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });
    try {
      final api = ApiServiceActualizado();
      
      // Usar los métodos correctos del API actualizado
      final futures = await Future.wait([
        api.getPropiedades().catchError((e) {
          debugPrint('Error cargando propiedades: $e');
          return <dynamic>[];
        }),
        api.getAreasComunes().catchError((e) {
          debugPrint('Error cargando áreas comunes: $e');
          return <dynamic>[];
        }),
        api.getAvisos().catchError((e) {
          debugPrint('Error cargando avisos: $e');
          return <dynamic>[];
        }),
        api.getReglas().catchError((e) {
          debugPrint('Error cargando reglas: $e');
          return <dynamic>[];
        }),
        // Note: No hay método de reservas en el API actualizado, usar lista vacía
        Future.value(<dynamic>[]).catchError((e) => <dynamic>[]),
      ]);

      if (mounted) {
        setState(() {
          propiedades = futures[0];
          areasComunes = futures[1];
          avisos = futures[2];
          reglas = futures[3];
          reservas = futures[4];
        });
      }
    } catch (e) {
      debugPrint('Error general en cargarCondominio: $e');
      if (mounted) {
        setState(() {
          error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Widget buildList(
    String title,
    List<dynamic>? items,
    String Function(dynamic) subtitle,
  ) {
    if (items == null) return const SizedBox.shrink();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('No hay $title registrados'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...items.map(
          (item) => Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                item['nombre'] ??
                    item['numero_casa'] ??
                    item['titulo'] ??
                    item['descripcion'] ??
                    'Sin nombre',
              ),
              subtitle: Text(subtitle(item)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Condominio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: () => _mostrarDialogoReserva(),
            tooltip: 'Nueva Reserva',
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('Error: $error'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildList(
                    'Propiedades',
                    propiedades,
                    (item) => 'Casa: ${item['numero_casa'] ?? ''}',
                  ),
                  buildList(
                    'Áreas Comunes',
                    areasComunes,
                    (item) =>
                        'Tipo: ${item['tipo'] ?? ''} - ${item['disponible'] == true ? 'Disponible' : 'No disponible'}',
                  ),
                  buildReservasList(),
                  buildList(
                    'Avisos',
                    avisos,
                    (item) => 'Fecha: ${item['fecha'] ?? ''}',
                  ),
                  buildList(
                    'Reglas',
                    reglas,
                    (item) => 'Descripción: ${item['descripcion'] ?? ''}',
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildReservasList() {
    if (reservas == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Reservas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarDialogoReserva(),
                icon: const Icon(Icons.add),
                label: const Text('Reservar'),
              ),
            ],
          ),
        ),
        if (reservas!.isEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No tienes reservas'),
          )
        else
          ...reservas!.map(
            (reserva) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(
                  Icons.event,
                  color: _getEstadoColor(reserva['estado']),
                ),
                title: Text(reserva['area_comun']?['nombre'] ?? 'Área común'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha: ${reserva['fecha'] ?? ''}'),
                    Text(
                      'Hora: ${reserva['hora_inicio'] ?? ''} - ${reserva['hora_fin'] ?? ''}',
                    ),
                    Text('Estado: ${reserva['estado'] ?? 'Pendiente'}'),
                  ],
                ),
                trailing: reserva['estado'] == 'pendiente'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _cancelarReserva(reserva['id']),
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado) {
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  void _mostrarDialogoReserva() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime fechaSeleccionada = DateTime.now();
        TimeOfDay horaInicio = TimeOfDay.now();
        TimeOfDay horaFin = TimeOfDay(
          hour: TimeOfDay.now().hour + 1,
          minute: TimeOfDay.now().minute,
        );
        dynamic areaSeleccionada;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nueva Reserva'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'Área Común',
                        border: OutlineInputBorder(),
                      ),
                      value: areaSeleccionada,
                      items: areasComunes
                          ?.where((area) => area['disponible'] == true)
                          .map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area['nombre'] ?? 'Sin nombre'),
                            );
                          })
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          areaSeleccionada = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Fecha'),
                      subtitle: Text(
                        '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final fecha = await showDatePicker(
                          context: context,
                          initialDate: fechaSeleccionada,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (fecha != null) {
                          setState(() {
                            fechaSeleccionada = fecha;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Hora de inicio'),
                      subtitle: Text(
                        '${horaInicio.hour}:${horaInicio.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: horaInicio,
                        );
                        if (hora != null) {
                          setState(() {
                            horaInicio = hora;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('Hora de fin'),
                      subtitle: Text(
                        '${horaFin.hour}:${horaFin.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: horaFin,
                        );
                        if (hora != null) {
                          setState(() {
                            horaFin = hora;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (areaSeleccionada != null) {
                      _crearReserva(
                        areaSeleccionada['id'],
                        fechaSeleccionada,
                        horaInicio,
                        horaFin,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Reservar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _crearReserva(
    int areaId,
    DateTime fecha,
    TimeOfDay horaInicio,
    TimeOfDay horaFin,
  ) async {
    try {
      final api = ApiService();
      // --- CORRECCIÓN AQUÍ ---
      await api.post('/api/finanzas/reservas/', {
        'area_comun_id': areaId,
        'fecha':
            '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}',
        'hora_inicio':
            '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}',
        'hora_fin':
            '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        cargarCondominio();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelarReserva(int reservaId) async {
    try {
      final api = ApiService();
      // --- CORRECCIÓN AQUÍ ---
      await api.post('/api/finanzas/reservas/$reservaId/cancelar/', {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
        cargarCondominio();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar reserva: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}