import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/modelos/venta.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/providers/ventas_provider.dart';
import 'package:cod_barras/servicios/escaner.dart';
import 'package:cod_barras/widgets/widget_buscador.dart';
import 'pantalla_reporteVenta.dart';

//Carrito de venta que contiene qué producto y cuánto se va a vender
class _LineaCarrito {
  final Producto producto;
  double cantidad;

  _LineaCarrito({required this.producto, required this.cantidad});

  double get subtotal => producto.precioVenta * cantidad;
  double get ganancia => producto.gananciaUnitaria * cantidad;
}

class PantallaVentas extends StatefulWidget {
  const PantallaVentas({super.key});

  @override
  State<PantallaVentas> createState() => _PantallaVentasState();
}

class _PantallaVentasState extends State<PantallaVentas> {
  final List<_LineaCarrito> _carrito = [];
  bool _guardando = false;

  double get _total => _carrito.fold(0, (suma, l) => suma + l.subtotal);

  //Agrega un producto al carrito. Si ya estaba, solo le suma 1
  void _agregarProducto(Producto producto) {
    final indiceExistente = _carrito.indexWhere((l) => l.producto.id == producto.id);
    setState(() {
      if (indiceExistente != -1) {
        _carrito[indiceExistente].cantidad += producto.permiteDecimales ? 0.1 : 1;
      } else {
        _carrito.add(_LineaCarrito(producto: producto, cantidad: producto.permiteDecimales ? 0.1 : 1));
      }
    });
  }

  Future<void> _escanear() async {
    final codigo = await abrirEscaner(context);
    if (codigo == null || !mounted) return;

    final inventario = context.read<InventarioProvider>();
    final producto = await inventario.buscarPorCodigo(codigo);
    if (!mounted) return;

    if (producto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El código "$codigo" no está registrado.')),
      );
      return;
    }
    if (producto.existencia <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${producto.nombre}" ya no tiene existencia.')),
      );
      return;
    }
    _agregarProducto(producto);
  }

  void _cambiarCantidad(int indice, double delta) {
    setState(() {
      final linea = _carrito[indice];
      final nuevaCantidad = linea.cantidad + delta;
      if (nuevaCantidad <= 0) {
        _carrito.removeAt(indice);
      } else {
        linea.cantidad = nuevaCantidad;
      }
    });
  }

  void _quitarLinea(int indice) {
    setState(() => _carrito.removeAt(indice));
  }

  Future<void> _confirmarVenta() async {
    if (_carrito.isEmpty) return;

    //Validación rápida en pantalla antes de mandarlo a la BD
    for (final linea in _carrito) {
      if (linea.cantidad > linea.producto.existencia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            'Solo quedan ${linea.producto.existencia} ${linea.producto.unidadMedida} de "${linea.producto.nombre}".',
          )),
        );
        return;
      }
    }

    setState(() => _guardando = true);
    final ventasProvider = context.read<VentasProvider>();
    final inventarioProvider = context.read<InventarioProvider>();

    final detalles = _carrito.map((linea) {
      return VentaDetalle(
        productoId: linea.producto.id!,
        nombreProducto: linea.producto.nombre,
        unidadMedida: linea.producto.unidadMedida,
        cantidad: linea.cantidad,
        precioUnitario: linea.producto.precioVenta,
        costoUnitario: linea.producto.precioCompra,
        subtotal: linea.subtotal,
        ganancia: linea.ganancia,
      );
    }).toList();

    //Guardamos el stock restante de cada producto para el reporte
    final existenciaRestante = <int, double>{
      for (final linea in _carrito)
        linea.producto.id!: linea.producto.existencia - linea.cantidad,
    };

    try {
      final venta = await ventasProvider.registrarVenta(detalles: detalles);
      await inventarioProvider.cargarProductos();
      if (!mounted) return;

      setState(() {
        _carrito.clear();
        _guardando = false;
      });

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PantallaReporteVenta(
            venta: venta,
            detalles: detalles,
            existenciaRestante: existenciaRestante,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la venta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventario = context.watch<InventarioProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _escanear,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear producto'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('o')),
                Expanded(child: Divider()),
              ],
            ),
          ),
          BuscadorProducto(
            inventarioProvider: inventario,
            alSeleccionar: (producto) {
              if (producto.existencia <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${producto.nombre}" ya no tiene existencia.')),
                );
                return;
              }
              _agregarProducto(producto);
            },
          ),
          const Divider(height: 24),
          Expanded(
            child: _carrito.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Escanea o busca productos para agregarlos a la venta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _carrito.length,
                    itemBuilder: (context, i) {
                      final linea = _carrito[i];
                      final decimales = linea.producto.permiteDecimales;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(linea.producto.nombre,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '\$${linea.producto.precioVenta.toStringAsFixed(2)} c/u  ·  '
                            'Subtotal: \$${linea.subtotal.toStringAsFixed(2)}',
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _quitarLinea(i),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _cambiarCantidad(i, decimales ? -0.1 : -1),
                              ),
                              Text(
                                linea.cantidad.toStringAsFixed(decimales ? 2 : 0),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _cambiarCantidad(i, decimales ? 0.1 : 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_carrito.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _confirmarVenta,
                    icon: _guardando
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.point_of_sale),
                    label: Text(_guardando ? 'Guardando...' : 'Confirmar venta'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
