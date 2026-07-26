import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/servicios/escaner.dart';
import 'package:cod_barras/widgets/widget_buscador.dart';
import 'package:cod_barras/widgets/card_producto.dart';
import 'package:cod_barras/pantallas/registro/pantalla_registrosProduc.dart';

class PantallaEntrada extends StatefulWidget {
  const PantallaEntrada({super.key});

  @override
  State<PantallaEntrada> createState() => _PantallaEntradaState();
}

class _PantallaEntradaState extends State<PantallaEntrada> {
  Producto? _productoSeleccionado;
  final _cantidadController = TextEditingController(text: '1');
  bool _guardando = false;

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _escanear() async {
    final codigo = await abrirEscaner(context);
    if (codigo == null || !mounted) return;

    final inventario = context.read<InventarioProvider>();
    final producto = await inventario.buscarPorCodigo(codigo);
    if (!mounted) return;

    if (producto == null) {
      _mostrarNoEncontrado(codigo);
      return;
    }
    setState(() => _productoSeleccionado = producto);
  }

  void _mostrarNoEncontrado(String codigo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no encontrado'),
        content: Text('El código "$codigo" no está registrado en el inventario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PantallaRegistro()));
            },
            child: const Text('Registrar producto'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEntrada() async {
    if (_productoSeleccionado == null) return;
    final cantidad = double.tryParse(_cantidadController.text.trim());
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una cantidad válida.')),
      );
      return;
    }

    setState(() => _guardando = true);
    final inventario = context.read<InventarioProvider>();
    await inventario.registrarEntrada(_productoSeleccionado!, cantidad);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        'Entrada registrada: +$cantidad ${_productoSeleccionado!.unidadMedida} de ${_productoSeleccionado!.nombre}',
      )),
    );
    setState(() {
      _productoSeleccionado = null;
      _cantidadController.text = '1';
      _guardando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventario = context.watch<InventarioProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Entrada de productos')),
      body: SingleChildScrollView(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _escanear,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear código'),
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
            alSeleccionar: (producto) => setState(() => _productoSeleccionado = producto),
          ),
          const Divider(height: 32),
          if (_productoSeleccionado != null) ...[
            ProductoCard(producto: _productoSeleccionado!),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: _productoSeleccionado!.permiteDecimales,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cantidad que entra (${_productoSeleccionado!.unidadMedida})',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _confirmarEntrada,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(_guardando ? 'Guardando...' : 'Confirmar entrada'),
                  ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Escanea un código o busca un producto para registrar su entrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
        ),
      ),
    );
  }
}
