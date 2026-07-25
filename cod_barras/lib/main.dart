import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/inventario_provider.dart';
import 'providers/escaner_provider.dart';
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
      ],
      child: MaterialApp(
        title: 'Inventario con código de barras',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const MenuPrincipal(),
      ),
    );
  }
}
