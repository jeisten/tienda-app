import 'package:sqflite/sqflite.dart';
import '../models/tienda.dart';
import 'database_helper.dart';

class TiendaDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Tienda tienda) async {
    final db = await _databaseHelper.database;
    return await db.insert('tiendas', tienda.toMap());
  }

  Future<List<Tienda>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tiendas');
    return List.generate(maps.length, (i) => Tienda.fromMap(maps[i]));
  }

  Future<List<Tienda>> getByPropietarioId(String propietarioId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tiendas',
      where: 'propietario_id = ?',
      whereArgs: [propietarioId],
    );
    return List.generate(maps.length, (i) => Tienda.fromMap(maps[i]));
  }

  Future<Tienda?> getById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tiendas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tienda.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Tienda>> getPendientesSincronizacion() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tiendas',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Tienda.fromMap(maps[i]));
  }

  Future<int> update(Tienda tienda) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tiendas',
      tienda.toMap(),
      where: 'id = ?',
      whereArgs: [tienda.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'tiendas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> marcarComoSincronizado(String id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tiendas',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
