import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/venta.dart';
import 'package:cod_barras/providers/negocio_provider.dart';
import 'pantalla_ticket.dart';

//Se muestra justo después de confirmar una venta.
//Muestra el folio, fecha, artículos vendidos, ganancia por artículo y total,
//el total cobrado y cuánto stock quedó de cada producto
class PantallaReporteVenta extends StatelessWidget {
  final Venta venta;
  final List<VentaDetalle> detalles;
  final Map<int, double> existenciaRestante;

  const PantallaReporteVenta({
    super.key,
    required this.venta,
    required this.detalles,
    required this.existenciaRestante,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(venta.fecha));

    return Scaffold(
      appBar: AppBar(title: Text('Venta #${venta.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Venta #${venta.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(fecha, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _filaResumen('Total cobrado', venta.total),
                  _filaResumen('Ganancia total', venta.gananciaTotal),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Artículos vendidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...detalles.map((detalle) {
            final restante = existenciaRestante[detalle.productoId];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(detalle.nombreProducto, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${detalle.cantidad.toStringAsFixed(detalle.cantidad % 1 == 0 ? 0 : 2)} ${detalle.unidadMedida}'
                  ' × \$${detalle.precioUnitario.toStringAsFixed(2)}'
                  '\nGanancia: \$${detalle.ganancia.toStringAsFixed(2)}'
                  '${restante != null ? '\nStock restante: ${restante.toStringAsFixed(restante % 1 == 0 ? 0 : 2)} ${detalle.unidadMedida}' : ''}',
                ),
                isThreeLine: true,
                trailing: Text(
                  '\$${detalle.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _generarTicket(context),
            icon: const Icon(Icons.receipt_long),
            label: const Text('Generar ticket para el cliente'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(String etiqueta, double valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta),
          Text('\$${valor.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _generarTicket(BuildContext context) async {
    final negocioProvider = context.read<NegocioProvider>();
    await negocioProvider.cargar();
    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaTicket(
          negocio: negocioProvider.negocio,
          venta: venta,
          detalles: detalles,
        ),
      ),
    );
  }
}
