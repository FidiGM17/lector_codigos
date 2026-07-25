import 'package:flutter/material.dart';

//Guarda el último código escaneado y si el flash está activo
class EscanerProvider extends ChangeNotifier {
  String? _ultimoCodigoEscaneado;
  String? get ultimoCodigoEscaneado => _ultimoCodigoEscaneado;

  void guardarUltimoCodigo(String codigo) {
    _ultimoCodigoEscaneado = codigo;
    notifyListeners();
  }

  void limpiar() {
    _ultimoCodigoEscaneado = null;
    notifyListeners();
  }
}
