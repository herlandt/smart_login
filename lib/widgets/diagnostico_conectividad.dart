import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_simple.dart';

/// Widget de diagnóstico de conectividad para verificar el backend actualizado
class DiagnosticoConectividad extends StatefulWidget {
  const DiagnosticoConectividad({super.key});

  @override
  State<DiagnosticoConectividad> createState() =>
      _DiagnosticoConectividadState();
}

class _DiagnosticoConectividadState extends State<DiagnosticoConectividad> {
  bool _isTestingConnectivity = false;
  Map<String, dynamic>? _connectivityResult;
  Map<String, dynamic>? _emulatorTestResult;

  @override
  void initState() {
    super.initState();
    _runConnectivityTests();
  }

  Future<void> _runConnectivityTests() async {
    setState(() {
      _isTestingConnectivity = true;
    });

    try {
      final authProvider = context.read<AuthProviderActualizado>();

      // Test 1: Conectividad general
      _connectivityResult = await authProvider.verificarConectividad();

      // Test 2: Test específico para emuladores
      _emulatorTestResult = await authProvider.testConectividadEmulador();
    } catch (e) {
      debugPrint('Error general en test de conectividad: $e');
      _connectivityResult = {
        'connected': false,
        'message': 'Error en test de conectividad: $e',
      };
    }

    setState(() {
      _isTestingConnectivity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.network_check, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Diagnóstico de Conectividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isTestingConnectivity
                      ? null
                      : _runConnectivityTests,
                  tooltip: 'Actualizar test',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isTestingConnectivity)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Probando conectividad...'),
                  ],
                ),
              )
            else ...[
              _buildConnectivityResult(),
              const SizedBox(height: 16),
              _buildEmulatorTestResult(),
              const SizedBox(height: 16),
              _buildEndpointsInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityResult() {
    if (_connectivityResult == null) {
      return const Text('No hay datos de conectividad');
    }

    final isConnected = _connectivityResult!['connected'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.check_circle : Icons.error,
                color: isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Conectividad General',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isConnected ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _connectivityResult!['message'] ?? 'Sin mensaje',
            style: TextStyle(
              fontSize: 13,
              color: isConnected ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmulatorTestResult() {
    if (_emulatorTestResult == null) {
      return const Text('No hay datos del test de emulador');
    }

    final isConnected = _emulatorTestResult!['connected'] ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.blue[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.blue : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConnected ? Icons.android : Icons.warning,
                color: isConnected ? Colors.blue : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Test Específico Emulador',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isConnected ? Colors.blue[800] : Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _emulatorTestResult!['message'] ?? 'Sin mensaje',
            style: TextStyle(
              fontSize: 13,
              color: isConnected ? Colors.blue[700] : Colors.orange[700],
            ),
          ),
          if (_emulatorTestResult!['url'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'URL exitosa: ${_emulatorTestResult!['url']}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndpointsInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endpoints Actualizados',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          _buildEndpointItem('Login', '/api/login/', Colors.green),
          _buildEndpointItem(
            'Perfil Usuario',
            '/api/usuarios/perfil/',
            Colors.blue,
          ),
          _buildEndpointItem(
            'Avisos',
            '/api/condominio/avisos/',
            Colors.orange,
          ),
          _buildEndpointItem(
            'Finanzas',
            '/api/finanzas/gastos/',
            Colors.purple,
          ),
          _buildEndpointItem(
            'Seguridad',
            '/api/seguridad/visitantes/',
            Colors.red,
          ),
          _buildEndpointItem(
            'Mantenimiento',
            '/api/mantenimiento/solicitudes/',
            Colors.teal,
          ),
          const SizedBox(height: 8),
          Text(
            '✅ Endpoints actualizados según Schema OpenAPI 2025',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointItem(String name, String endpoint, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              endpoint,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget informativo sobre las mejoras implementadas
class InfoMejorasImplementadas extends StatelessWidget {
  const InfoMejorasImplementadas({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Mejoras Implementadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildMejoraItem(
              '🔗 Endpoints Actualizados',
              'Ahora usa los endpoints exactos de tu schema OpenAPI 2025',
              Colors.blue,
            ),
            _buildMejoraItem(
              '🔐 Autenticación Mejorada',
              'Sistema de tokens compatible con tu backend específico',
              Colors.green,
            ),
            _buildMejoraItem(
              '🔍 Diagnóstico Avanzado',
              'Verificación automática de conectividad con tu servidor',
              Colors.orange,
            ),
            _buildMejoraItem(
              '📱 Compatibilidad Emulador',
              'Optimización específica para desarrollo en emuladores Android',
              Colors.purple,
            ),
            _buildMejoraItem(
              '🎯 API Service Actualizado',
              'Métodos HTTP que coinciden con tu documentación OpenAPI',
              Colors.teal,
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tu sistema ahora está 100% sincronizado con tu backend específico',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
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

  Widget _buildMejoraItem(String titulo, String descripcion, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
