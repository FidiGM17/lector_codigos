import 'package:cod_barras/BD/infraestructura_bd.dart';
import 'package:cod_barras/modelos/negocio.dart';
import 'package:sqflite/sqflite.dart';

//Acceso a los datos del perfil del negocio
class RepoNegocio {
  final InfraestructuraBD _infraestructura = InfraestructuraBD.instancia;

  Future<Negocio> obtener() async {
    final db = await _infraestructura.database;
    final resultados = await db.query('negocio', where: 'id = 1', limit: 1);
    if (resultados.isEmpty) return const Negocio();
    return Negocio.fromMap(resultados.first);
  }

  Future<void> guardar(Negocio negocio) async {
    final db = await _infraestructura.database;
    await db.insert(
      'negocio',
      negocio.toMap()..['id'] = 1,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}