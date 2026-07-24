//MODELO DE LOS MOVIMIENTOS DE LOS PRODUCTOS
//Tipos de movimientos posibles para un producto
enum TipoMovimiento { entrada, salida }

extension TipoMovimientoTexto on TipoMovimiento {
  String get valor => this == TipoMovimiento.entrada ? 'entrada' : 'salida';

  static TipoMovimiento desdeTexto(String texto) {
    return texto == 'entrada' ? TipoMovimiento.entrada : TipoMovimiento.salida;
  }
}

//Representa un movimiento de inventario ya sea entrada o salida
//Guardar el historial completo y permite generar reportes después
class Movimiento {
  final int? id;
  final int productoId;
  final TipoMovimiento tipo;
  final double cantidad;
  final String fecha;

  Movimiento({
    this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto_id': productoId,
      'tipo': tipo.valor,
      'cantidad': cantidad,
      'fecha': fecha,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      productoId: map['producto_id'] as int,
      tipo: TipoMovimientoTexto.desdeTexto(map['tipo'] as String),
      cantidad: (map['cantidad'] as num).toDouble(),
      fecha: map['fecha'] as String,
    );
  }
}
