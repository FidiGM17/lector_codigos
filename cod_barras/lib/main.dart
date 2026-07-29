import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inventario_provider.dart';
import 'providers/escaner_provider.dart';
import 'providers/modoOsc_provider.dart';
import 'pantallas/menu/menu_prin.dart';

void main() {
  runApp(const AppInventario());
}

class AppInventario extends StatelessWidget {
  const AppInventario({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => EscanerProvider()),
        ChangeNotifierProvider(create: (_) => TemaProvider()),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, tema, _) => MaterialApp(
          title: 'Inventario con código de barras',
          debugShowCheckedModeBanner: false,
          themeMode: tema.modo,
          theme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          home: const MenuPrincipal(),
        ),
      ),
    );
  }
}
