//MODELO DEL NEGOCIO
//Posee los datos de la tienda que se imprimen en el encabezado del ticket
class Negocio {
  final int id;
  final String nombre;
  final String domicilio;
  final String telefono;
  final String? logoPath;//Ruta local de la imagen del logo del usuario
  final String mensajeTicket;//Mensaje al final del ticket, el usuario lo edita a gusto

  const Negocio({
    this.id = 1,
    this.nombre = '',
    this.domicilio = '',
    this.telefono = '',
    this.logoPath,
    this.mensajeTicket = 'Gracias por su compra. ¡Vuelva pronto!',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'domicilio': domicilio,
      'telefono': telefono,
      'logo_path': logoPath,
      'mensaje_ticket': mensajeTicket,
    };
  }

  factory Negocio.fromMap(Map<String, dynamic> map) {
    return Negocio(
      id: map['id'] as int? ?? 1,
      nombre: map['nombre'] as String? ?? '',
      domicilio: map['domicilio'] as String? ?? '',
      telefono: map['telefono'] as String? ?? '',
      logoPath: map['logo_path'] as String?,
      mensajeTicket: map['mensaje_ticket'] as String? ??
          'Gracias por su compra. ¡Vuelva pronto!',
    );
  }

  Negocio copyWith({
    String? nombre,
    String? domicilio,
    String? telefono,
    String? logoPath,
    bool borrarLogo = false,
    String? mensajeTicket,
  }) {
    return Negocio(
      id: id,
      nombre: nombre ?? this.nombre,
      domicilio: domicilio ?? this.domicilio,
      telefono: telefono ?? this.telefono,
      logoPath: borrarLogo ? null : (logoPath ?? this.logoPath),
      mensajeTicket: mensajeTicket ?? this.mensajeTicket,
    );
  }
}
