import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cod_barras/modelos/negocio.dart';
import 'package:cod_barras/providers/negocio_provider.dart';

//Pantalla de personalización del negocio
class PantallaNegocio extends StatefulWidget {
  const PantallaNegocio({super.key});

  @override
  State<PantallaNegocio> createState() => _PantallaNegocioState();
}

class _PantallaNegocioState extends State<PantallaNegocio> {
  final _nombreController = TextEditingController();
  final _domicilioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _mensajeController = TextEditingController();
  String? _logoPath;
  bool _controladoresListos = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<NegocioProvider>();
      await provider.cargar();
      if (!mounted) return;
      _llenarControladores(provider.negocio);
    });
  }

  void _llenarControladores(Negocio negocio) {
    setState(() {
      _nombreController.text = negocio.nombre;
      _domicilioController.text = negocio.domicilio;
      _telefonoController.text = negocio.telefono;
      _mensajeController.text = negocio.mensajeTicket;
      _logoPath = negocio.logoPath;
      _controladoresListos = true;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _domicilioController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _elegirLogo() async {
    final XFile? imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 85,
    );
    if (imagen == null) return;


    final directorio = await getApplicationDocumentsDirectory();
    final extension = p.extension(imagen.path);
    final destino = p.join(directorio.path, 'logo_negocio$extension');
    await File(imagen.path).copy(destino);

    setState(() => _logoPath = destino);
  }

  void _quitarLogo() {
    setState(() => _logoPath = null);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final negocio = Negocio(
      nombre: _nombreController.text.trim(),
      domicilio: _domicilioController.text.trim(),
      telefono: _telefonoController.text.trim(),
      logoPath: _logoPath,
      mensajeTicket: _mensajeController.text.trim().isEmpty
          ? 'Gracias por su compra. ¡Vuelva pronto!'
          : _mensajeController.text.trim(),
    );

    await context.read<NegocioProvider>().guardar(negocio);
    if (!mounted) return;
    setState(() => _guardando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos del negocio guardados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del negocio')),
      body: !_controladoresListos
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _elegirLogo,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _logoPath != null ? FileImage(File(_logoPath!)) : null,
                      child: _logoPath == null
                          ? const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: _elegirLogo,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(_logoPath == null ? 'Subir logo' : 'Cambiar logo'),
                      ),
                      if (_logoPath != null)
                        TextButton.icon(
                          onPressed: _quitarLogo,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Quitar', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del negocio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _domicilioController,
                  decoration: const InputDecoration(
                    labelText: 'Domicilio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mensajeController,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje al final del ticket',
                    helperText: 'Ej: "Gracias por su compra. ¡Feliz Navidad!"',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(_guardando ? 'Guardando...' : 'Guardar datos del negocio'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ),
    );
  }
}
