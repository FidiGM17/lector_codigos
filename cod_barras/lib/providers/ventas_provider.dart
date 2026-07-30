import 'package:flutter/material.dart';
import 'package:cod_barras/BD/repositorios/repo_ventas.dart';
import 'package:cod_barras/modelos/venta.dart';

export 'package:cod_barras/BD/repositorios/repo_ventas.dart' show StockInsuficienteException;

//Capa intermedia entre la pantalla de ventas y el repositorio de ventas
class VentasProvider extends ChangeNotifier {
  final RepoVentas _repoVentas = RepoVentas();

  //Registra y descuenta el stock.
  Future<Venta> registrarVenta({
    required List<VentaDetalle> detalles,
  }) async {
    final total = detalles.fold<double>(0, (suma, d) => suma + d.subtotal);
    final gananciaTotal = detalles.fold<double>(0, (suma, d) => suma + d.ganancia);

    final venta = Venta(
      fecha: DateTime.now().toIso8601String(),
      total: total,
      gananciaTotal: gananciaTotal,
    );

    return _repoVentas.registrarVenta(venta: venta, detalles: detalles);
  }

  Future<List<Venta>> historial() => _repoVentas.listarTodas();

  Future<List<VentaDetalle>> detallesDeVenta(int ventaId) =>
      _repoVentas.detallesDeVenta(ventaId);
}
