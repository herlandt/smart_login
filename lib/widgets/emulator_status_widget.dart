import 'package:flutter/material.dart';
import '../services/emulator_network_service.dart';
import '../config/api_config.dart';

/// Widget que muestra el estado de conectividad específico para emuladores
class EmulatorStatusWidget extends StatefulWidget {
  const EmulatorStatusWidget({super.key});

  @override
  State<EmulatorStatusWidget> createState() => _EmulatorStatusWidgetState();
}

class _EmulatorStatusWidgetState extends State<EmulatorStatusWidget> {
  bool _isLoading = true;
  bool _isConnected = false;
  Map<String, dynamic> _diagnostics = {};
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    setState(() => _isLoading = true);

    try {
      // Obtener URL optimizada
      _currentUrl = await EmulatorNetworkService.findOptimalUrl();

      // Ejecutar test de conectividad
      _isConnected = await EmulatorNetworkService.runConnectivityTest();

      // Obtener diagnósticos
      _diagnostics = await EmulatorNetworkService.diagnoseNetworkIssues();
    } catch (e) {
      _isConnected = false;
      _diagnostics = {'error': e.toString()};
    }

    setState(() => _isLoading = false);
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
            // Header
            Row(
              children: [
                Icon(Icons.android, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Estado del Emulador',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _checkConnectivity,
                ),
              ],
            ),
            const Divider(),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Estado de conectividad
              _buildStatusRow(
                'Conectividad',
                _isConnected ? 'Conectado' : 'Desconectado',
                _isConnected ? Colors.green : Colors.red,
                _isConnected ? Icons.check_circle : Icons.error,
              ),

              // URL actual
              _buildInfoRow('URL Actual', _currentUrl),

              // Entorno
              _buildInfoRow('Entorno', ApiConfig.currentEnvironment),

              // Internet
              if (_diagnostics['internet_connectivity'] != null)
                _buildStatusRow(
                  'Internet',
                  _diagnostics['internet_connectivity'] ? 'OK' : 'Sin acceso',
                  _diagnostics['internet_connectivity']
                      ? Colors.green
                      : Colors.orange,
                  _diagnostics['internet_connectivity']
                      ? Icons.wifi
                      : Icons.wifi_off,
                ),

              // Backend status
              if (_diagnostics['backend_status'] != null) ...[
                const SizedBox(height: 8),
                _buildStatusRow(
                  'Backend',
                  _diagnostics['backend_status']['status'] == 'online'
                      ? 'Online'
                      : 'Offline',
                  _diagnostics['backend_status']['status'] == 'online'
                      ? Colors.green
                      : Colors.red,
                  _diagnostics['backend_status']['status'] == 'online'
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                ),
              ],

              // Sección de troubleshooting si hay problemas
              if (!_isConnected) ...[
                const SizedBox(height: 16),
                const Text(
                  'Solución de Problemas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTroubleshootingTips(),
              ],

              // URLs probadas
              if (_diagnostics['tested_urls'] != null) ...[
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('URLs Probadas'),
                  leading: const Icon(Icons.link),
                  children: [
                    ..._diagnostics['tested_urls']
                        .map<Widget>(
                          (url) => ListTile(
                            leading: const Icon(Icons.circle, size: 8),
                            title: Text(url.toString()),
                            dense: true,
                          ),
                        )
                        .toList(),
                  ],
                ),
              ],

              // Botón de test completo
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _runFullDiagnostic,
                  icon: const Icon(Icons.medical_services),
                  label: const Text('Ejecutar Diagnóstico Completo'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingTips() {
    final tips = [
      '1. Verificar que Django esté ejecutándose: python manage.py runserver 0.0.0.0:8000',
      '2. Verificar firewall de Windows en puerto 8000',
      '3. Confirmar IP de la PC en la red: ipconfig',
      '4. Reiniciar emulador si persisten problemas',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips
          .map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                tip,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          )
          .toList(),
    );
  }

  Future<void> _runFullDiagnostic() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Ejecutando diagnóstico completo...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    await _checkConnectivity();

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isConnected
                ? '✅ Diagnóstico completado: Todo OK'
                : '❌ Diagnóstico completado: Problemas detectados',
          ),
          backgroundColor: _isConnected ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
