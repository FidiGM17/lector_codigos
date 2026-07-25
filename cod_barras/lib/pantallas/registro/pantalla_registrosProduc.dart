import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/providers/inventario_provider.dart';
import 'package:cod_barras/servicios/escaner.dart';
import 'package:cod_barras/widgets/cat_desplegable.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();

  String? _categoriaSeleccionada;
  String _unidadMedida = 'pieza';
  bool _esGranel = false;
  bool _guardando = false;

  static const List<String> _unidades = ['pieza', 'kg', 'g', 'litro', 'ml'];

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _escanear() async {
    final codigo = await abrirEscaner(context);
    if (codigo == null || !mounted) return;

    //Verifica que no exista ya un producto con ese código
    final inventario = context.read<InventarioProvider>();
    final existente = await inventario.buscarPorCodigo(codigo);
    if (!mounted) return;

    if (existente != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Este código ya está registrado como "${existente.nombre}".')),
      );
      return;
    }
    setState(() => _codigoController.text = codigo);
  }

  //Genera un código interno para productos sin código de barras
  void _generarCodigoInterno() {
    final sufijo = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final prefijo = _esGranel ? 'GRANEL' : 'INT';
    setState(() => _codigoController.text = '$prefijo-$sufijo');
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    final inventario = context.read<InventarioProvider>();

    try {
      await inventario.registrarProducto(
        codigo: _codigoController.text.trim(),
        nombre: _nombreController.text.trim(),
        categoria: _categoriaSeleccionada!,
        existenciaInicial: double.parse(_cantidadController.text.trim()),
        unidadMedida: _unidadMedida,
        permiteDecimales: _esGranel,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto registrado correctamente.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error. Es posible que el código ya exista')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaHoy = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Registro de producto nuevo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            
            //Código de barras / QR
            TextFormField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: 'Código de barras / QR',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _escanear,
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _generarCodigoInterno,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generar código interno'),
              ),
            ),
            const SizedBox(height: 8),

            //Nombre
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            //Categoría
            CategoriaDesplegable(
              valorSeleccionado: _categoriaSeleccionada,
              onChanged: (v) => setState(() => _categoriaSeleccionada = v),
            ),
            const SizedBox(height: 16),

            //Producto a granel
            SwitchListTile(
              title: const Text('¿Es un producto a granel?'),
              subtitle: const Text('Permite cantidades con decimales (kg, litros, etc.)'),
              value: _esGranel,
              onChanged: (v) => setState(() {
                _esGranel = v;
                _unidadMedida = v ? 'kg' : 'pieza';
              }),
            ),
            const SizedBox(height: 8),

            //Unidad de medida
            DropdownButtonFormField<String>(
              value: _unidadMedida,
              decoration: const InputDecoration(
                labelText: 'Unidad de medida',
                border: OutlineInputBorder(),
              ),
              items: _unidades
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => setState(() => _unidadMedida = v ?? 'pieza'),
            ),
            const SizedBox(height: 16),

            //Cantidad total
            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad total (existencia inicial)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: _esGranel),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                final numero = double.tryParse(v.trim());
                if (numero == null || numero < 0) return 'Cantidad inválida';
                return null;
              },
            ),
            const SizedBox(height: 16),

            //Fecha de registro
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha de ingreso'),
              subtitle: Text(fechaHoy),
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar producto'),
            ),
          ],
        ),
      ),
    );
  }
}
