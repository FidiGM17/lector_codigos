//MODELO DE LOS PRODUCTOS
//Representa un producto del inventario
class Producto {
  final int? id;
  final String codigo;//Código de barras o propio según sea el caso
  final String nombre;
  final String categoria;
  final double existencia;
  final String unidadMedida;//pieza, kg, litro, etc
  final bool permiteDecimales;//El valor es TRUE para productos a granel
  final String fechaRegistro;

  Producto({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.existencia,
    this.unidadMedida = 'pieza',
    this.permiteDecimales = false,
    required this.fechaRegistro,
  });

  //Convierte el objeto a un "map" para poder guardarlo en la BD
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'categoria': categoria,
      'existencia': existencia,
      'unidad_medida': unidadMedida,
      'permite_decimales': permiteDecimales ? 1 : 0,
      'fecha_registro': fechaRegistro,
    };
  }

  //Crea un objeto "Producto"
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      categoria: map['categoria'] as String,
      existencia: (map['existencia'] as num).toDouble(),
      unidadMedida: map['unidad_medida'] as String? ?? 'pieza',
      permiteDecimales: (map['permite_decimales'] as int? ?? 0) == 1,
      fechaRegistro: map['fecha_registro'] as String,
    );
  }

  //Crea una copia del producto cambiando solo los campos indicados
  Producto copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? categoria,
    double? existencia,
    String? unidadMedida,
    bool? permiteDecimales,
    String? fechaRegistro,
  }) {
    return Producto(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      existencia: existencia ?? this.existencia,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      permiteDecimales: permiteDecimales ?? this.permiteDecimales,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
