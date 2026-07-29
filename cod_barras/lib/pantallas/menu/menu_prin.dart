import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cod_barras/providers/modoOsc_provider.dart';
import 'package:cod_barras/pantallas/registro/pantalla_registrosProduc.dart';
import 'package:cod_barras/pantallas/entrada/pantalla_entradaProduc.dart';
import 'package:cod_barras/pantallas/salida/pantalla_salidaProduc.dart';
import 'package:cod_barras/pantallas/reportes/pantalla_reportes.dart';
import 'package:cod_barras/pantallas/productos/pantalla_listaProduc.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<TemaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            tooltip: tema.esOscuro ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
            icon: Icon(tema.esOscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => context.read<TemaProvider>().alternar(),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [

          //Botón de registro de productos nuevos
          _BotonMenu(
            icono: Icons.add_box_outlined,
            texto: 'Registro de\nproductos nuevos',
            color: Colors.blue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaRegistro())),
          ),

          //Botón de ingreso de productos
          _BotonMenu(
            icono: Icons.arrow_downward_rounded,
            texto: 'Entrada de\nproductos',
            color: Colors.green,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEntrada())),
          ),

          //Botón de salida/venta de productos
          _BotonMenu(
            icono: Icons.arrow_upward_rounded,
            texto: 'Salida de\nproductos',
            color: Colors.orange,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaSalida())),
          ),

          //Botón del reporte de los movimientos
          _BotonMenu(
            icono: Icons.bar_chart_rounded,
            texto: 'Reporte de\ninventario',
            color: Colors.purple,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaReportes())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PantallaListaProductos())),
        icon: const Icon(Icons.list_alt),
        label: const Text('Ver / editar productos'),
      ),
    );
  }
}

class _BotonMenu extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const _BotonMenu({
    required this.icono,
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
