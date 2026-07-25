import 'package:cod_barras/BD/infraestructura_bd.dart';
import 'package:cod_barras/modelos/movimiento.dart';

//Acceso a datos del historial de movimientos
//Esto nos ayudará en el apartado de los reportes
class RepoMovimiento {
  final InfraestructuraBD _infraestructura = InfraestructuraBD.instancia;

  //Registra un movimiento nuevo ya sea de entrada o salida
  Future<int> registrar(Movimiento movimiento) async {
    final db = await _infraestructura.database;
    return await db.insert('movimientos', movimiento.toMap()..remove('id'));
  }

  //Historial completo de un producto específico
  Future<List<Movimiento>> historialPorProducto(int productoId) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'movimientos',
      where: 'producto_id = ?',
      whereArgs: [productoId],
      orderBy: 'fecha DESC',
    );
    return resultados.map((fila) => Movimiento.fromMap(fila)).toList();
  }

  //Todos los movimientos entre dos fechas
  Future<List<Movimiento>> historialPorRangoFechas(
    String fechaInicio,
    String fechaFin,
  ) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'movimientos',
      where: 'fecha BETWEEN ? AND ?',
      whereArgs: [fechaInicio, fechaFin],
      orderBy: 'fecha DESC',
    );
    return resultados.map((fila) => Movimiento.fromMap(fila)).toList();
  }

  //Todos los movimientos para un reporte general
  Future<List<Movimiento>> listarTodos() async {
    final db = await _infraestructura.database;
    final resultados = await db.query('movimientos', orderBy: 'fecha DESC');
    return resultados.map((fila) => Movimiento.fromMap(fila)).toList();
  }
}