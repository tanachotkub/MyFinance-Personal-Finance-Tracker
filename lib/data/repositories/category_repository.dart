import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Category>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories', orderBy: 'type DESC, name ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<Category>> getByType(String type) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<int> insert(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}