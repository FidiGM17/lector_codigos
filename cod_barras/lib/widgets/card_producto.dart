import 'package:flutter/material.dart';
import '../modelos/producto.dart';

//Tarjeta que muestra nombre, categoría y stock de un producto
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final bool stockBajo = producto.existencia <= 3;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          producto.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${producto.categoria}\nCódigo: ${producto.codigo}',
        ),
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: stockBajo ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            stockBajo ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            color: stockBajo ? Colors.red : Colors.green,
          ),
        ),
        trailing: trailing ??
            Text(
              '${producto.existencia.toStringAsFixed(producto.permiteDecimales ? 2 : 0)} ${producto.unidadMedida}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: stockBajo ? Colors.red : Colors.black87,
              ),
            ),
      ),
    );
  }
}
