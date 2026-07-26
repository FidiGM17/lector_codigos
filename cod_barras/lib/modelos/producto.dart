//MODELO DE LOS PRODUCTOS
//Representa un producto del inventario
class Producto {
  final int? id;
  final String codigo;//código de barras real, o creado por el usuario
  final String nombre;
  final String categoria;
  final double existencia;
  final String unidadMedida;//pieza, kg, litro, ml, etc
  final bool permiteDecimales;//El valor TRUE aparece para productos a granel
  final String fechaRegistro;
  final double precioCompra;//Lo que cuesta el producto comprarlo al proveedor
  final double precioVenta;//Lo que cuesta el producto al público 

  Producto({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.existencia,
    this.unidadMedida = 'pieza',
    this.permiteDecimales = false,
    required this.fechaRegistro,
    this.precioCompra = 0,
    this.precioVenta = 0,
  });

  //Ganancia por artículo vendido (precio de venta - precio de compra)
  double get gananciaUnitaria => precioVenta - precioCompra;

  //Ganancia futura si es que se vendiera todo el stock actual
  double get gananciaPotencialTotal => gananciaUnitaria * existencia;

  //Convierte el objeto a un "Map" para poder guardarlo en SQLite
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
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
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
      precioCompra: (map['precio_compra'] as num?)?.toDouble() ?? 0,
      precioVenta: (map['precio_venta'] as num?)?.toDouble() ?? 0,
    );
  }

  //Crea una copia del producto
  Producto copyWith({
    int? id,
    String? codigo,
    String? nombre,
    String? categoria,
    double? existencia,
    String? unidadMedida,
    bool? permiteDecimales,
    String? fechaRegistro,
    double? precioCompra,
    double? precioVenta,
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
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
    );
  }
}