import 'package:cod_barras/BD/infraestructura_bd.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:sqflite/sqflite.dart';


//Las pantallas le piden las acciones a este repositorio en un lenguaje simple
class RepoProducto {
  final InfraestructuraBD _infraestructura = InfraestructuraBD.instancia;

  //Inserta un producto nuevo
  //Retorna el id generado o lanza una excepción si el código ya existe
  Future<int> insertar(Producto producto) async {
    final db = await _infraestructura.database;
    return await db.insert(
      'productos',
      producto.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  //Actualiza los datos de un producto ya existente
  Future<void> actualizar(Producto producto) async {
    final db = await _infraestructura.database;
    await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  //Busca un producto por su código exacto (usando el escaneo)
  //No retorna nada si dicho código no existe
  Future<Producto?> buscarPorCodigo(String codigo) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'productos',
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );
    if (resultados.isEmpty) return null;
    return Producto.fromMap(resultados.first);
  }

  //Busca productos cuyo nombre contenga el texto ingresado
  //Es una búsqueda manual por si un producto no tiene código
  Future<List<Producto>> buscarPorNombre(String texto) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'productos',
      where: 'nombre LIKE ?',
      whereArgs: ['%$texto%'],
      orderBy: 'nombre ASC',
    );
    return resultados.map((fila) => Producto.fromMap(fila)).toList();
  }

  //Lista todos los productos, se pueden filtrar por categoría
  Future<List<Producto>> listarTodos({String? categoria}) async {
    final db = await _infraestructura.database;
    final resultados = await db.query(
      'productos',
      where: categoria != null ? 'categoria = ?' : null,
      whereArgs: categoria != null ? [categoria] : null,
      orderBy: 'nombre ASC',
    );
    return resultados.map((fila) => Producto.fromMap(fila)).toList();
  }

  //Suma X cantidad al stock actual
  Future<void> incrementarExistencia(int productoId, double cantidad) async {
    final db = await _infraestructura.database;
    await db.rawUpdate(
      'UPDATE productos SET existencia = existencia + ? WHERE id = ?',
      [cantidad, productoId],
    );
  }

  //Resta X cantidad al stock actual, no permite que el stock baje de 0
  Future<bool> decrementarExistencia(int productoId, double cantidad) async {
    final db = await _infraestructura.database;
    final producto = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [productoId],
      limit: 1,
    );
    if (producto.isEmpty) return false;

    final existenciaActual = (producto.first['existencia'] as num).toDouble();
    if (existenciaActual < cantidad) return false; //No hay suficiente stock

    await db.rawUpdate(
      'UPDATE productos SET existencia = existencia - ? WHERE id = ?',
      [cantidad, productoId],
    );
    return true;
  }

  //Elimina un producto y sus movimientos
  Future<void> eliminar(int productoId) async {
    final db = await _infraestructura.database;
    await db.delete('productos', where: 'id = ?', whereArgs: [productoId]);
  }
}