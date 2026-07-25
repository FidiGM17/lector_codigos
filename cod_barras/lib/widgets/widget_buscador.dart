import 'package:flutter/material.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'card_producto.dart';

//Barra de búsqueda por nombre y lista de resultados
//Es una alternativa al escaneo para cuando el producto no tiene código
class BuscadorProducto extends StatefulWidget {
  final InventarioProvider inventarioProvider;
  final void Function(Producto producto) alSeleccionar;

  const BuscadorProducto({
    super.key,
    required this.inventarioProvider,
    required this.alSeleccionar,
  });

  @override
  State<BuscadorProducto> createState() => _BuscadorProductoState();
}

class _BuscadorProductoState extends State<BuscadorProducto> {
  final TextEditingController _controlador = TextEditingController();
  List<Producto> _resultados = [];
  bool _buscando = false;

  Future<void> _buscar(String texto) async {
    if (texto.trim().isEmpty) {
      setState(() => _resultados = []);
      return;
    }
    setState(() => _buscando = true);
    final resultados = await widget.inventarioProvider.buscarPorNombre(texto.trim());
    setState(() {
      _resultados = resultados;
      _buscando = false;
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _controlador,
            decoration: InputDecoration(
              labelText: 'Buscar producto por nombre',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _controlador.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controlador.clear();
                        _buscar('');
                      },
                    ),
            ),
            onChanged: _buscar,
          ),
        ),
        if (_buscando) const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        ),
        if (!_buscando && _resultados.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _resultados.length,
              itemBuilder: (context, i) => ProductoCard(
                producto: _resultados[i],
                onTap: () => widget.alSeleccionar(_resultados[i]),
              ),
            ),
          ),
        if (!_buscando && _controlador.text.isNotEmpty && _resultados.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No se encontraron productos con ese nombre.'),
          ),
      ],
    );
  }
}
