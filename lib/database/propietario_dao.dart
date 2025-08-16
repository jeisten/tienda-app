import 'package:sqflite/sqflite.dart';
import '../models/propietario.dart';
import 'database_helper.dart';

class PropietarioDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Propietario propietario) async {
    final db = await _databaseHelper.database;
    return await db.insert('propietarios', propietario.toMap());
  }

  Future<List<Propietario>> getAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('propietarios');
    return List.generate(maps.length, (i) => Propietario.fromMap(maps[i]));
  }

  Future<Propietario?> getById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'propietarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Propietario.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Propietario>> getPendientesSincronizacion() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'propietarios',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Propietario.fromMap(maps[i]));
  }

  Future<int> update(Propietario propietario) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'propietarios',
      propietario.toMap(),
      where: 'id = ?',
      whereArgs: [propietario.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'propietarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> marcarComoSincronizado(String id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'propietarios',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
