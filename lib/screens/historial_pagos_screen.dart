import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';

class HistorialPagosScreen extends StatefulWidget {
  const HistorialPagosScreen({super.key});

  @override
  State<HistorialPagosScreen> createState() => _HistorialPagosScreenState();
}

class _HistorialPagosScreenState extends State<HistorialPagosScreen> {
  final PaymentService _paymentService = PaymentService();
  List<TransaccionPago> _transacciones = [];
  bool _cargando = true;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
    });

    try {
      final historial = await _paymentService.obtenerHistorial();
      setState(() {
        _transacciones = historial;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar historial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<TransaccionPago> get _transaccionesFiltradas {
    if (_filtroEstado == null) return _transacciones;
    return _transacciones.where((t) => t.estado.codigo == _filtroEstado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (valor) {
              setState(() {
                _filtroEstado = valor == 'todos' ? null : valor;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Text('Todos'),
              ),
              ...EstadoPago.values.map((estado) => PopupMenuItem(
                value: estado.codigo,
                child: Text(estado.nombre),
              )),
            ],
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _transacciones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No hay transacciones registradas'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarHistorial,
                  child: Column(
                    children: [
                      // Estadísticas
                      _buildEstadisticas(),
                      // Lista de transacciones
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transaccionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final transaccion = _transaccionesFiltradas[index];
                            return _buildTransaccionCard(transaccion);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEstadisticas() {
    final exitosas = _transacciones.where((t) => t.estado == EstadoPago.exitoso).length;
    final fallidas = _transacciones.where((t) => t.estado == EstadoPago.fallido).length;
    final pendientes = _transacciones.where((t) => t.estado == EstadoPago.pendiente || t.estado == EstadoPago.procesando).length;
    final totalMonto = _transacciones
        .where((t) => t.estado == EstadoPago.exitoso)
        .fold(0.0, (sum, t) => sum + t.monto);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen de Transacciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEstadisticaItem(
                      'Exitosas',
                      exitosas.toString(),
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                  Expanded(
                    child: _buildEstadisticaItem(
                      'Fallidas',
                      fallidas.toString(),
                      Colors.red,
                      Icons.error,
                    ),
                  ),
                  Expanded(
                    child: _buildEstadisticaItem(
                      'Pendientes',
                      pendientes.toString(),
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pagado:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Bs. ${totalMonto.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, Color color, IconData icono) {
    return Column(
      children: [
        Icon(icono, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTransaccionCard(TransaccionPago transaccion) {
    final isReembolso = transaccion.monto < 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getColorEstado(transaccion.estado),
          child: Icon(
            _getIconoMetodo(transaccion.metodo),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                isReembolso ? 'Reembolso' : transaccion.metodo.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${isReembolso ? '-' : ''}Bs. ${transaccion.monto.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isReembolso ? Colors.orange : Colors.green,
                fontSize: 16,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaccion.descripcion ?? 'Sin descripción',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getColorEstado(transaccion.estado),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaccion.estado.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transaccion.fecha),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetalleItem('ID de Transacción', transaccion.id),
                if (transaccion.referencia != null)
                  _buildDetalleItem('Referencia', transaccion.referencia!),
                _buildDetalleItem(
                  'Fecha Completa',
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(transaccion.fecha),
                ),
                if (transaccion.detallesMetodo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Detalles del Método:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...transaccion.detallesMetodo!.entries.map((entry) =>
                    _buildDetalleItem(
                      _formatearClave(entry.key),
                      entry.value.toString(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (transaccion.estado == EstadoPago.exitoso && !isReembolso)
                      ElevatedButton.icon(
                        onPressed: () => _solicitarReembolso(transaccion),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Reembolso'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _compartirComprobante(transaccion),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Compartir'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$titulo:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorEstado(EstadoPago estado) {
    switch (estado) {
      case EstadoPago.exitoso:
        return Colors.green;
      case EstadoPago.fallido:
        return Colors.red;
      case EstadoPago.pendiente:
        return Colors.orange;
      case EstadoPago.procesando:
        return Colors.blue;
      case EstadoPago.cancelado:
        return Colors.grey;
    }
  }

  IconData _getIconoMetodo(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.tarjetaCredito:
      case MetodoPago.tarjetaDebito:
        return Icons.credit_card;
      case MetodoPago.transferenciaBancaria:
        return Icons.account_balance;
      case MetodoPago.qr:
        return Icons.qr_code;
      case MetodoPago.efectivo:
        return Icons.money;
    }
  }

  String _formatearClave(String clave) {
    return clave
        .split('_')
        .map((palabra) => palabra[0].toUpperCase() + palabra.substring(1))
        .join(' ');
  }

  Future<void> _solicitarReembolso(TransaccionPago transaccion) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar Reembolso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transacción: ${transaccion.id}'),
            Text('Monto: Bs. ${transaccion.monto.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('¿Estás seguro de que deseas solicitar un reembolso?'),
            const SizedBox(height: 8),
            const Text(
              'Nota: El reembolso puede tardar de 5 a 10 días hábiles en procesarse.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Solicitar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await _paymentService.procesarReembolso(transaccion.id, transaccion.monto);
        await _cargarHistorial();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reembolso procesado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar reembolso: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _compartirComprobante(TransaccionPago transaccion) {
    final comprobante = '''
COMPROBANTE DE PAGO
==================

ID: ${transaccion.id}
Monto: Bs. ${transaccion.monto.toStringAsFixed(2)}
Método: ${transaccion.metodo.nombre}
Estado: ${transaccion.estado.nombre}
Fecha: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(transaccion.fecha)}
${transaccion.referencia != null ? 'Referencia: ${transaccion.referencia}' : ''}

Smart Condominio
''';

    // Aquí podrías integrar con el plugin share_plus para compartir
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprobante'),
        content: SingleChildScrollView(
          child: Text(comprobante),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}