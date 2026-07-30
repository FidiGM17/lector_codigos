import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cod_barras/modelos/negocio.dart';
import 'package:cod_barras/modelos/venta.dart';

//Genera el PDF del ticket que se le entrega al cliente después de una venta
class ServicioTicketPdf {
  static Future<Uint8List> construir({
    required Negocio negocio,
    required Venta venta,
    required List<VentaDetalle> detalles,
  }) async {
    final documento = pw.Document();
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(venta.fecha));

    //Si el negocio tiene un logo guardado se carga como imagen
    pw.MemoryImage? logo;
    if (negocio.logoPath != null && negocio.logoPath!.isNotEmpty) {
      final archivo = File(negocio.logoPath!);
      if (await archivo.exists()) {
        logo = pw.MemoryImage(await archivo.readAsBytes());
      }
    }

    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [

              //Encabezado con el logo y datos del negocio
              if (logo != null) ...[
                pw.Image(logo, height: 60),
                pw.SizedBox(height: 6),
              ],
              if (negocio.nombre.isNotEmpty)
                pw.Text(
                  negocio.nombre,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              if (negocio.domicilio.isNotEmpty)
                pw.Text(negocio.domicilio, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),
              if (negocio.telefono.isNotEmpty)
                pw.Text('Tel: ${negocio.telefono}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center),

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Venta #${venta.id}', style: const pw.TextStyle(fontSize: 9)),
                  pw.Text(fecha, style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
              pw.Divider(),

              //Encabezado de la tabla de artículos
              pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.Text('Producto', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('Cant', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 3, child: pw.Text('P.Unit', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  pw.Expanded(flex: 3, child: pw.Text('Importe', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(),

              ...detalles.map((detalle) {
                final cantidadTexto = detalle.cantidad % 1 == 0
                    ? detalle.cantidad.toStringAsFixed(0)
                    : detalle.cantidad.toStringAsFixed(2);
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(flex: 4, child: pw.Text(detalle.nombreProducto, style: const pw.TextStyle(fontSize: 9))),
                      pw.Expanded(flex: 2, child: pw.Text(cantidadTexto, style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 3, child: pw.Text('\$${detalle.precioUnitario.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                      pw.Expanded(flex: 3, child: pw.Text('\$${detalle.subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
              }),

              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${venta.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 12),

              //Mensaje al final del ticket, editable en el apartado "Datos del negocio"
              if (negocio.mensajeTicket.isNotEmpty)
                pw.Text(
                  negocio.mensajeTicket,
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
            ],
          );
        },
      ),
    );

    return documento.save();
  }
}
