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
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().cargarProductos();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventario = context.watch<InventarioProvider>();
    final texto = _busqueda.trim().toLowerCase();
    final productos = texto.isEmpty
        ? inventario.productos
        : inventario.productos.where((p) {
            return p.nombre.toLowerCase().contains(texto) ||
                p.codigo.toLowerCase().contains(texto);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Productos registrados')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o código',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _busqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          setState(() => _busqueda = '');
                        },
                      ),
              ),
              onChanged: (valor) => setState(() => _busqueda = valor),
            ),
          ),
          Expanded(
            child: inventario.cargando
                ? const Center(child: CircularProgressIndicator())
                : productos.isEmpty
                    ? Center(
                        child: Text(
                          texto.isEmpty
                              ? 'No hay productos registrados.'
                              : 'Ningún producto coincide con "$texto".',
                        ),
                      )
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
          ),
        ],
      ),
    );
  }
}
