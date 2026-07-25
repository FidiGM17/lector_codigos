import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

//Aísla el paquete de escaneo del resto de la app
class Escaner extends StatefulWidget {
  //Se manda llamar con el texto leído (el código de barras o QR) apenas se detecta
  final void Function(String codigo) alDetectar;

  const Escaner({super.key, required this.alDetectar});

  @override
  State<Escaner> createState() => _EscanerState();
}

class _EscanerState extends State<Escaner> {
  final MobileScannerController _controlador = MobileScannerController();
  bool _yaDetecto = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alCapturar(BarcodeCapture captura) {
    if (_yaDetecto) return;
    final codigos = captura.barcodes;
    if (codigos.isEmpty) return;

    final valor = codigos.first.rawValue;
    if (valor == null || valor.isEmpty) return;

    _yaDetecto = true;
    widget.alDetectar(valor);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: _controlador,
          onDetect: _alCapturar,
        ),

        //Cuadrito para guiar al usuario sobre a dónde debe apuntar
        Container(
          width: 250,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.greenAccent, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

//Abre la cámara en una pantalla completa y regresa el código leído
//O no regresa nada si el usuario cancela
Future<String?> abrirEscaner(BuildContext context) async {
  return Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Escanear código')),
        body: Escaner(
          alDetectar: (codigo) => Navigator.pop(context, codigo),
        ),
      ),
    ),
  );
}
