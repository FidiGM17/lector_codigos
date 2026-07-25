import 'package:flutter/material.dart';
import 'package:cod_barras/pantallas/registro/pantalla_registrosProduc.dart';
import 'package:cod_barras/pantallas/entrada/pantalla_entradaProduc.dart';
import 'package:cod_barras/pantallas/salida/pantalla_salidaProduc.dart';
import 'package:cod_barras/pantallas/reportes/pantalla_reportes.dart';
import 'package:cod_barras/pantallas/productos/pantalla_listaProduc.dart';

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _BotonMenu(
            icono: Icons.add_box_outlined,
            texto: 'Registro de\nproductos nuevos',
            color: Colors.blue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaRegistro())),
          ),
          _BotonMenu(
            icono: Icons.arrow_downward_rounded,
            texto: 'Entrada de\nproductos',
            color: Colors.green,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEntrada())),
          ),
          _BotonMenu(
            icono: Icons.arrow_upward_rounded,
            texto: 'Salida de\nproductos',
            color: Colors.orange,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaSalida())),
          ),
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
      color: color.withOpacity(0.1),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}
