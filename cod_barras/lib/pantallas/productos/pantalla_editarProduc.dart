import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/servicios/escaner.dart';
import 'package:cod_barras/widgets/cat_desplegable.dart';

//Permite editar código del producto, nombre, categoría y unidad de un producto
class PantallaEditarProducto extends StatefulWidget {
  final Producto producto;
  const PantallaEditarProducto({super.key, required this.producto});

  @override
  State<PantallaEditarProducto> createState() => _PantallaEditarProductoState();
}

class _PantallaEditarProductoState extends State<PantallaEditarProducto> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late String? _categoriaSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: widget.producto.codigo);
    _nombreController = TextEditingController(text: widget.producto.nombre);
    _categoriaSeleccionada = widget.producto.categoria;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _escanearNuevoCodigo() async {
    final codigo = await abrirEscaner(context);
    if (codigo == null || !mounted) return;
    setState(() => _codigoController.text = codigo);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final productoActualizado = widget.producto.copyWith(
      codigo: _codigoController.text.trim(),
      nombre: _nombreController.text.trim(),
      categoria: _categoriaSeleccionada,
    );

    try {
      await context.read<InventarioProvider>().editarProducto(productoActualizado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar: verifica que el código no esté repetido.')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _confirmarEliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres eliminar "${widget.producto.nombre}"? '
            'Esto también borrará su historial de movimientos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    await context.read<InventarioProvider>().eliminarProducto(widget.producto.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: 'Código de barras / interno',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _escanearNuevoCodigo,
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            CategoriaDesplegable(
              valorSeleccionado: _categoriaSeleccionada,
              onChanged: (v) => setState(() => _categoriaSeleccionada = v),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Existencia actual'),
              subtitle: Text('${widget.producto.existencia} ${widget.producto.unidadMedida}'
                  ' (usa Entrada/Salida para modificarla)'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _confirmarEliminar,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Eliminar producto', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
