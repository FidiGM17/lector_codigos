import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/widgets/card_producto.dart';
import 'pantalla_editarProduc.dart';

class PantallaListaProductos extends StatefulWidget {
  const PantallaListaProductos({super.key});

  @override
  State<PantallaListaProductos> createState() => _PantallaListaProductosState();
}

class _PantallaListaProductosState extends State<PantallaListaProductos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventario = context.watch<InventarioProvider>();
    final productos = inventario.productos;

    return Scaffold(
      appBar: AppBar(title: const Text('Productos registrados')),
      body: inventario.cargando
          ? const Center(child: CircularProgressIndicator())
          : productos.isEmpty
              ? const Center(child: Text('No hay productos registrados.'))
              : ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, i) => ProductoCard(
                    producto: productos[i],
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PantallaEditarProducto(producto: productos[i]),
                        ),
                      );
                      if (mounted) {
                        context.read<InventarioProvider>().cargarProductos();
                      }
                    },
                  ),
                ),
    );
  }
}
