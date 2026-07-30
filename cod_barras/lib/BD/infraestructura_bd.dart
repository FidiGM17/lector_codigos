import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//El script se encarga de la infraestructura de la BD
//Nos crea el archivo .db, se definen las tablas y manejar así futuras migraciones
//No contiene lógica de negocio porque eso está en BD/repositorios
class InfraestructuraBD {
  //Se usa el patrón singleton y esto garantiza que solo exista una conexión abierta
  //a la base de datos en toda la app
  static final InfraestructuraBD instancia = InfraestructuraBD._interno();
  static Database? _database;

  InfraestructuraBD._interno();

  //Se sube este número cada vez que se cambie la estructura de las tablas
  //en una versión futura de la app
  //NOTA: cada vez que se agregue una migración nueva en _alActualizar,
  //este número debe subir también o sqflite nunca ejecutará esa migración
  //en los dispositivos que ya tengan una base de datos creada
  static const int _versionBD = 4;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _inicializarBD();
    return _database!;
  }

  Future<Database> _inicializarBD() async {
    final rutaBD = await getDatabasesPath();
    final ruta = join(rutaBD, 'inventario.db');
    return await openDatabase(
      ruta,
      version: _versionBD,
      onCreate: _alCrear,
      onUpgrade: _alActualizar,
    );
  }

  //La creación de las tablas se ejecuta solo la primera vez que un dispositivo abre la app
  //es decir, aún no existe y se encargará de crearlas
  Future<void> _alCrear(Database db, int version) async {
    //Tabla de productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT UNIQUE NOT NULL,
        nombre TEXT NOT NULL,
        categoria TEXT NOT NULL,
        existencia REAL NOT NULL DEFAULT 0,
        unidad_medida TEXT NOT NULL DEFAULT 'pieza',
        permite_decimales INTEGER NOT NULL DEFAULT 0,
        fecha_registro TEXT NOT NULL,
        precio_compra REAL NOT NULL DEFAULT 0,
        precio_venta REAL NOT NULL DEFAULT 0,
        presentacion REAL NOT NULL DEFAULT 0
      )
    ''');

    //Tabla de los movimientos de los productos
    await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        producto_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        cantidad REAL NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (producto_id) REFERENCES productos (id) ON DELETE CASCADE
      )
    ''');

    //Índices para que las búsquedas por código y por nombre sean rápidas
    await db.execute('CREATE INDEX idx_productos_codigo ON productos (codigo)');
    await db.execute('CREATE INDEX idx_productos_nombre ON productos (nombre)');
    await db.execute('CREATE INDEX idx_movimientos_producto ON movimientos (producto_id)');

    await _crearTablasVentasYNegocio(db);
  }

  //Tabla de ventas
  Future<void> _crearTablasVentasYNegocio(Database db) async {
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        ganancia_total REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE venta_detalle (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        nombre_producto TEXT NOT NULL,
        unidad_medida TEXT NOT NULL DEFAULT 'pieza',
        cantidad REAL NOT NULL,
        precio_unitario REAL NOT NULL,
        costo_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        ganancia REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas (id) ON DELETE CASCADE,
        FOREIGN KEY (producto_id) REFERENCES productos (id)
      )
    ''');

    await db.execute('CREATE INDEX idx_venta_detalle_venta ON venta_detalle (venta_id)');

    //Tabla de datos del negocio
    await db.execute('''
      CREATE TABLE negocio (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        nombre TEXT NOT NULL DEFAULT '',
        domicilio TEXT NOT NULL DEFAULT '',
        telefono TEXT NOT NULL DEFAULT '',
        logo_path TEXT,
        mensaje_ticket TEXT NOT NULL DEFAULT 'Gracias por su compra. ¡Vuelva pronto!'
      )
    ''');

    await db.insert('negocio', {
      'id': 1,
      'nombre': '',
      'domicilio': '',
      'telefono': '',
      'logo_path': null,
      'mensaje_ticket': 'Gracias por su compra. ¡Vuelva pronto!',
    });
  }


  //Aquí agregamos las columnas de precio a quien ya tenía la app instalada
  Future<void> _alActualizar(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE productos ADD COLUMN precio_compra REAL NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE productos ADD COLUMN precio_venta REAL NOT NULL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE productos ADD COLUMN presentacion REAL NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await _crearTablasVentasYNegocio(db);
    }
  }

  Future<void> cerrar() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
