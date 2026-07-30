import 'package:cod_barras/BD/infraestructura_bd.dart';
import 'package:cod_barras/modelos/venta.dart';

//Mensaje que se lanza cuando ya no hay suficiente stock para completar la venta
class StockInsuficienteException implements Exception {
  final String mensaje;
  StockInsuficienteException(this.mensaje);
  @override
  String toString() => mensaje;
}

//Acceso a datos de las ventas
class RepoVentas {
  final InfraestructuraBD _infraestructura = InfraestructuraBD.instancia;

  //Registra la venta completa y actualiza stock
  //Si algo falla, no se descuenta nada ni se guarda nada a medias
  Future<Venta> registrarVenta({
    required Venta venta,
    required List<VentaDetalle> detalles,
  }) async {
    final db = await _infraestructura.database;

    late final int ventaId;

    await db.transaction((txn) async {
      //Se revisa que haya stock suficiente para no dejar la venta a medias
      for (final detalle in detalles) {
        final filas = await txn.query(
          'productos',
          where: 'id = ?',
          whereArgs: [detalle.productoId],
          limit: 1,
        );
        if (filas.isEmpty) {
          throw StockInsuficienteException(
            'El producto "${detalle.nombreProducto}" ya no existe en el inventario.',
          );
        }
        final existencia = (filas.first['existencia'] as num).toDouble();
        if (existencia < detalle.cantidad) {
          throw StockInsuficienteException(
            'No hay suficiente stock de "${detalle.nombreProducto}" '
            '(quedan $existencia ${detalle.unidadMedida}).',
          );
        }
      }

      //Se descuenta el stock de cada producto
      for (final detalle in detalles) {
        await txn.rawUpdate(
          'UPDATE productos SET existencia = existencia - ? WHERE id = ?',
          [detalle.cantidad, detalle.productoId],
        );
      }

      ventaId = await txn.insert('ventas', venta.toMap()..remove('id'));

      for (final detalle in detalles) {
        await txn.insert(
          'venta_detalle',
          (detalle.toMap()
            ..remove('id')
            ..['venta_id'] = ventaId),
        );
      }
    });

    return Venta(
      id: ventaId,
      fecha: venta.fecha,
      total: venta.total,
      gananciaTotal: venta.gananciaTotal,
    );
  }

  Future<List<VentaDetalle>> detallesDeVenta(int ventaId) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'venta_detalle',
      where: 'venta_id = ?',
      whereArgs: [ventaId],
    );
    return resultados.map((fila) => VentaDetalle.fromMap(fila)).toList();
  }

  //Historial de ventas
  Future<List<Venta>> listarTodas() async {
    final db = await _infraestructura.database;
    final resultados = await db.query('ventas', orderBy: 'fecha DESC');
    return resultados.map((fila) => Venta.fromMap(fila)).toList();
  }
}
