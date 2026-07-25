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
  static const int _versionBD = 1;

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
        fecha_registro TEXT NOT NULL
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
  }


  Future<void> _alActualizar(Database db, int oldVersion, int newVersion) async {
    //Sin migraciones todavía es la primera versión de la app
  }

  Future<void> cerrar() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
