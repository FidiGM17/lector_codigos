import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/servicios/escaner.dart';
import 'package:cod_barras/widgets/widget_buscador.dart';
import 'package:cod_barras/widgets/card_producto.dart';

class PantallaSalida extends StatefulWidget {
  const PantallaSalida({super.key});

  @override
  State<PantallaSalida> createState() => _PantallaSalidaState();
}

class _PantallaSalidaState extends State<PantallaSalida> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El código "$codigo" no está registrado.')),
      );
      return;
    }
    setState(() => _productoSeleccionado = producto);
  }

  Future<void> _confirmarSalida() async {
    if (_productoSeleccionado == null) return;
    final cantidad = double.tryParse(_cantidadController.text.trim());
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una cantidad válida.')),
      );
      return;
    }

    if (cantidad > _productoSeleccionado!.existencia) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Solo quedan ${_productoSeleccionado!.existencia} ${_productoSeleccionado!.unidadMedida} disponibles.',
        )),
      );
      return;
    }

    setState(() => _guardando = true);
    final inventario = context.read<InventarioProvider>();
    final exito = await inventario.registrarSalida(_productoSeleccionado!, cantidad);

    if (!mounted) return;

    if (!exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay suficiente stock para esta salida.')),
      );
      setState(() => _guardando = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        'Salida registrada: -$cantidad ${_productoSeleccionado!.unidadMedida} de ${_productoSeleccionado!.nombre}',
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
      appBar: AppBar(title: const Text('Salida de productos')),
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
                      labelText: 'Cantidad que sale (${_productoSeleccionado!.unidadMedida})',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _guardando ? null : _confirmarSalida,
                    icon: const Icon(Icons.remove_circle_outline),
                    label: Text(_guardando ? 'Guardando...' : 'Confirmar salida'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700),
                  ),
                ],
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Escanea un código o busca un producto para registrar su salida.',
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
