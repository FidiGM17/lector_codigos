import 'package:flutter/material.dart';
import 'package:cod_barras/BD/repositorios/repo_movimientos.dart';
import 'package:cod_barras/BD/repositorios/repo_producto.dart';
import 'package:cod_barras/modelos/producto.dart';
import 'package:cod_barras/modelos/movimiento.dart';

//Capa intermedia entre las pantallas y los repositorios
//Las pantallas llaman métodos de aquí y este provider es quien habla con los repositorios
class InventarioProvider extends ChangeNotifier {
  final RepoProducto _repoProducto = RepoProducto();
  final RepoMovimiento _repoMovimiento = RepoMovimiento();

  List<Producto> _productos = [];
  List<Producto> get productos => _productos;

  bool _cargando = false;
  bool get cargando => _cargando;

  //Carga la lista completa de productos
  Future<void> cargarProductos({String? categoria}) async {
    _cargando = true;
    notifyListeners();
    _productos = await _repoProducto.listarTodos(categoria: categoria);
    _cargando = false;
    notifyListeners();
  }

  //Registrar un producto nuevo
  Future<Producto> registrarProducto({
    required String codigo,
    required String nombre,
    required String categoria,
    required double existenciaInicial,
    String unidadMedida = 'pieza',
    bool permiteDecimales = false,
  }) async {
    final producto = Producto(
      codigo: codigo,
      nombre: nombre,
      categoria: categoria,
      existencia: existenciaInicial,
      unidadMedida: unidadMedida,
      permiteDecimales: permiteDecimales,
      fechaRegistro: DateTime.now().toIso8601String(),
    );
    final id = await _repoProducto.insertar(producto);
    return producto.copyWith(id: id);
  }

  Future<void> editarProducto(Producto producto) async {
    await _repoProducto.actualizar(producto);
  }

  //Elimina un producto y su historial de movimientos
  Future<void> eliminarProducto(int productoId) async {
    await _repoProducto.eliminar(productoId);
  }

  Future<Producto?> buscarPorCodigo(String codigo) {
    return _repoProducto.buscarPorCodigo(codigo);
  }

  Future<List<Producto>> buscarPorNombre(String texto) {
    return _repoProducto.buscarPorNombre(texto);
  }

  //Registra una entrada, añade al contador y guarda el movimiento
  Future<void> registrarEntrada(Producto producto, double cantidad) async {
    await _repoProducto.incrementarExistencia(producto.id!, cantidad);
    await _repoMovimiento.registrar(Movimiento(
      productoId: producto.id!,
      tipo: TipoMovimiento.entrada,
      cantidad: cantidad,
      fecha: DateTime.now().toIso8601String(),
    ));
  }

  //Registra una salida, resta al contador y guarda el movimiento
  Future<bool> registrarSalida(Producto producto, double cantidad) async {
    final exito = await _repoProducto.decrementarExistencia(producto.id!, cantidad);
    if (!exito) return false;

    await _repoMovimiento.registrar(Movimiento(
      productoId: producto.id!,
      tipo: TipoMovimiento.salida,
      cantidad: cantidad,
      fecha: DateTime.now().toIso8601String(),
    ));
    return true;
  }

  Future<List<Movimiento>> historialDeProducto(int productoId) {
    return _repoMovimiento.historialPorProducto(productoId);
  }

  Future<List<Movimiento>> historialCompleto() {
    return _repoMovimiento.listarTodos();
  }
}
