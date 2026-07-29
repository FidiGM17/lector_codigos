import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Controla si la app usa el modo claro u oscuro
class TemaProvider extends ChangeNotifier {
  static const String _clavePreferencia = 'modo_oscuro';

  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;

  bool get esOscuro => _modo == ThemeMode.dark;

  TemaProvider() {
    _cargarPreferenciaGuardada();
  }

  //Lee el modo guardado
  //Si se usa por primera vez la app, se queda en modo claro
  Future<void> _cargarPreferenciaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final oscuroGuardado = prefs.getBool(_clavePreferencia) ?? false;
    _modo = oscuroGuardado ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  //Cambia el modo y guarda la elección para la siguiente vez que se abra la app
  Future<void> alternar() async {
    _modo = _modo == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clavePreferencia, _modo == ThemeMode.dark);
  }
}
