import 'package:flutter/material.dart';
import '../modelos/categoria.dart';

//Menú desplegable de categoría
class CategoriaDesplegable extends StatelessWidget {
  final String? valorSeleccionado;
  final void Function(String?) onChanged;

  const CategoriaDesplegable({
    super.key,
    required this.valorSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valorSeleccionado,
      decoration: const InputDecoration(
        labelText: 'Sección / Categoría',
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items: Categoria.lista
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: onChanged,
      validator: (valor) => valor == null ? 'Selecciona una categoría' : null,
    );
  }
}
