import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tiendas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla Propietarios
    await db.execute('''
      CREATE TABLE propietarios (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        direccion TEXT NOT NULL,
        telefono TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0
      )
    ''');

    // Tabla Tiendas
    await db.execute('''
      CREATE TABLE tiendas (
        id TEXT PRIMARY KEY,
        propietario_id TEXT NOT NULL,
        fecha_permiso TEXT NOT NULL,
        foto_url TEXT,
        certificado_bomberos TEXT,
        sayco_acinpro TEXT,
        latitud REAL,
        longitud REAL,
        direccion_tienda TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sincronizado INTEGER DEFAULT 0,
        FOREIGN KEY (propietario_id) REFERENCES propietarios (id)
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
