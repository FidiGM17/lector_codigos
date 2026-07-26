import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/categoria.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/widgets/card_producto.dart';

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _PantallaReportesState();
}

class _PantallaReportesState extends State<PantallaReportes> {
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    
    //Carga inicial de productos al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().cargarProductos();
    });
  }

  void _aplicarFiltro(String? categoria) {
    setState(() => _categoriaFiltro = categoria);
    context.read<InventarioProvider>().cargarProductos(categoria: categoria);
  }

  @override
  Widget build(BuildContext context) {
    final inventario = context.watch<InventarioProvider>();
    final productos = inventario.productos;

    final totalPiezas = productos.fold<double>(0, (suma, p) => suma + p.existencia);
    final stockBajo = productos.where((p) => p.existencia <= 3).length;
    final gananciaPotencial = productos.fold<double>(
      0, (suma, p) => suma + p.gananciaPotencialTotal,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de inventario')),
      body: Column(
        children: [

          //Resumen general
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _TarjetaResumen(
                    titulo: 'Productos',
                    valor: '${productos.length}',
                    icono: Icons.category_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TarjetaResumen(
                    titulo: 'Existencia total',
                    valor: totalPiezas.toStringAsFixed(0),
                    icono: Icons.inventory_2_outlined,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TarjetaResumen(
                    titulo: 'Stock bajo',
                    valor: '$stockBajo',
                    icono: Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          //Filtro por categoría
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.teal.withOpacity(0.08),
              child: ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.teal),
                title: const Text('Ganancia potencial del inventario actual'),
                subtitle: const Text('Si se vendiera toda la existencia al precio de venta registrado'),
                trailing: Text(
                  '\$${gananciaPotencial.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Filtro por categoría
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String?>(
              value: _categoriaFiltro,
              decoration: const InputDecoration(
                labelText: 'Filtrar por categoría',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todas las categorías')),
                ...Categoria.lista.map((c) => DropdownMenuItem(value: c, child: Text(c))),
              ],
              onChanged: _aplicarFiltro,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: inventario.cargando
                ? const Center(child: CircularProgressIndicator())
                : productos.isEmpty
                    ? const Center(child: Text('No hay productos registrados'))
                    : ListView.builder(
                        itemCount: productos.length,
                        itemBuilder: (context, i) => ProductoCard(producto: productos[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _TarjetaResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 6),
            Text(valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            Text(titulo, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
