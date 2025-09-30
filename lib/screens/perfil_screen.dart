import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? perfil;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await ApiService().getPerfilUsuario();
      setState(() {
        perfil = res;
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

  // Funciones auxiliares para extraer datos del perfil
  String _extractInitial(Map<String, dynamic> perfil) {
    final name = _extractName(perfil);
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
  }

  String _extractName(Map<String, dynamic> perfil) {
    // Primero intenta obtener el nombre del usuario anidado
    if (perfil['usuario'] != null && perfil['usuario'] is Map) {
      final usuario = perfil['usuario'] as Map<String, dynamic>;
      if (usuario['first_name'] != null &&
          usuario['first_name'].toString().isNotEmpty) {
        final firstName = usuario['first_name'].toString();
        final lastName = usuario['last_name']?.toString() ?? '';
        return '$firstName $lastName'.trim();
      }
      if (usuario['username'] != null) {
        return usuario['username'].toString();
      }
    }

    // Luego intenta campos directos
    if (perfil['nombre'] != null && perfil['nombre'].toString().isNotEmpty) {
      return perfil['nombre'].toString();
    }
    if (perfil['username'] != null &&
        perfil['username'].toString().isNotEmpty) {
      return perfil['username'].toString();
    }

    return 'Usuario';
  }

  String? _extractEmail(Map<String, dynamic> perfil) {
    // Intenta obtener email del usuario anidado
    if (perfil['usuario'] != null && perfil['usuario'] is Map) {
      final usuario = perfil['usuario'] as Map<String, dynamic>;
      if (usuario['email'] != null) {
        return usuario['email'].toString();
      }
    }

    // Luego campo directo
    if (perfil['email'] != null) {
      return perfil['email'].toString();
    }

    return null;
  }

  String? _extractPhone(Map<String, dynamic> perfil) {
    final fields = ['telefono', 'phone', 'celular'];
    for (final field in fields) {
      if (perfil[field] != null && perfil[field].toString().isNotEmpty) {
        return perfil[field].toString();
      }
    }
    return null;
  }

  String? _extractProperty(Map<String, dynamic> perfil) {
    // Intenta obtener de propiedad anidada
    if (perfil['propiedad'] != null && perfil['propiedad'] is Map) {
      final propiedad = perfil['propiedad'] as Map<String, dynamic>;
      if (propiedad['numero_casa'] != null) {
        return 'Casa ${propiedad['numero_casa']}';
      }
    }

    // Campos directos
    final fields = ['numero_casa', 'numero_departamento', 'propiedad'];
    for (final field in fields) {
      if (perfil[field] != null && perfil[field].toString().isNotEmpty) {
        return perfil[field].toString();
      }
    }

    return null;
  }

  Widget _buildInfoCard(String title, String? value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'No disponible',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar el perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: cargarPerfil,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : perfil == null
          ? const Center(child: Text('No hay datos de perfil'))
          : RefreshIndicator(
              onRefresh: cargarPerfil,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Avatar y nombre principal
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              _extractInitial(perfil!),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _extractName(perfil!),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_extractProperty(perfil!) != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Propiedad: ${_extractProperty(perfil!)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información de contacto
                    _buildInfoCard(
                      'Correo Electrónico',
                      _extractEmail(perfil!),
                      Icons.email_outlined,
                    ),
                    _buildInfoCard(
                      'Teléfono',
                      _extractPhone(perfil!),
                      Icons.phone_outlined,
                    ),

                    // Información adicional si existe
                    if (perfil!['documento'] != null)
                      _buildInfoCard(
                        'Documento',
                        perfil!['documento'].toString(),
                        Icons.badge_outlined,
                      ),
                    if (perfil!['fecha_registro'] != null)
                      _buildInfoCard(
                        'Miembro desde',
                        perfil!['fecha_registro'].toString(),
                        Icons.calendar_today_outlined,
                      ),
                    if (perfil!['estado'] != null)
                      _buildInfoCard(
                        'Estado',
                        perfil!['estado'].toString(),
                        Icons.verified_user_outlined,
                      ),

                    const SizedBox(height: 24),

                    // Botón de editar perfil
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar edición de perfil
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de edición en desarrollo'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar Perfil'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
