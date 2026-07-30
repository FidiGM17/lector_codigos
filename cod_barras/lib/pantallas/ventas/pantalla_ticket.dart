import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cod_barras/modelos/negocio.dart';
import 'package:cod_barras/modelos/venta.dart';
import 'package:cod_barras/servicios/ticketPDF.dart';

//Vista del ticket en PDF con botones para imprimir, compartir o guardar el archivo
class PantallaTicket extends StatelessWidget {
  final Negocio negocio;
  final Venta venta;
  final List<VentaDetalle> detalles;

  const PantallaTicket({
    super.key,
    required this.negocio,
    required this.venta,
    required this.detalles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ticket de venta #${venta.id}')),
      body: PdfPreview(
        build: (formato) => ServicioTicketPdf.construir(
          negocio: negocio,
          venta: venta,
          detalles: detalles,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        pdfFileName: 'ticket_venta_${venta.id}.pdf',
      ),
    );
  }
}
