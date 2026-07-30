//MODELO DE LAS VENTAS

class Venta {
  final int? id;
  final String fecha;
  final double total;
  final double gananciaTotal;

  Venta({
    this.id,
    required this.fecha,
    required this.total,
    required this.gananciaTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'total': total,
      'ganancia_total': gananciaTotal,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map['id'] as int?,
      fecha: map['fecha'] as String,
      total: (map['total'] as num).toDouble(),
      gananciaTotal: (map['ganancia_total'] as num).toDouble(),
    );
  }
}

//La venta contiene qué producto se vendió, cuánto se vendió y a qué precio
//Si el producto cambia de precio o se elimina, el historial de esa venta se queda
class VentaDetalle {
  final int? id;
  final int? ventaId;
  final int productoId;
  final String nombreProducto;
  final String unidadMedida;
  final double cantidad;
  final double precioUnitario;
  final double costoUnitario;
  final double subtotal;
  final double ganancia;

  VentaDetalle({
    this.id,
    this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.unidadMedida,
    required this.cantidad,
    required this.precioUnitario,
    required this.costoUnitario,
    required this.subtotal,
    required this.ganancia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'venta_id': ventaId,
      'producto_id': productoId,
      'nombre_producto': nombreProducto,
      'unidad_medida': unidadMedida,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'costo_unitario': costoUnitario,
      'subtotal': subtotal,
      'ganancia': ganancia,
    };
  }

  factory VentaDetalle.fromMap(Map<String, dynamic> map) {
    return VentaDetalle(
      id: map['id'] as int?,
      ventaId: map['venta_id'] as int?,
      productoId: map['producto_id'] as int,
      nombreProducto: map['nombre_producto'] as String,
      unidadMedida: map['unidad_medida'] as String? ?? 'pieza',
      cantidad: (map['cantidad'] as num).toDouble(),
      precioUnitario: (map['precio_unitario'] as num).toDouble(),
      costoUnitario: (map['costo_unitario'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      ganancia: (map['ganancia'] as num).toDouble(),
    );
  }
}
