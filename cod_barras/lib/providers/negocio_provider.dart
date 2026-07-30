import 'package:flutter/material.dart';
import 'package:cod_barras/BD/repositorios/repo_negocio.dart';
import 'package:cod_barras/modelos/negocio.dart';

//Mantiene en memoria los datos del negocio para llamarse en cada ticket
class NegocioProvider extends ChangeNotifier {
  final RepoNegocio _repoNegocio = RepoNegocio();

  Negocio _negocio = const Negocio();
  Negocio get negocio => _negocio;

  bool _cargando = false;
  bool get cargando => _cargando;

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();
    _negocio = await _repoNegocio.obtener();
    _cargando = false;
    notifyListeners();
  }

  Future<void> guardar(Negocio negocio) async {
    await _repoNegocio.guardar(negocio);
    _negocio = negocio;
    notifyListeners();
  }
}
