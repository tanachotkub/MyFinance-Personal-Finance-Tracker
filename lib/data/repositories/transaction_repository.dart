import 'package:sqflite/sqflite.dart' as sqflite; // ← เพิ่ม alias
import '../database/database_helper.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Query พร้อม JOIN category
  static const String _selectWithCategory = '''
    SELECT 
      t.*,
      c.name  AS category_name,
      c.icon  AS category_icon,
      c.color AS category_color
    FROM transactions t
    LEFT JOIN categories c ON t.category_id = c.id
  ''';

  Future<List<Transaction>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery(
      '$_selectWithCategory ORDER BY t.date DESC, t.created_at DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  Future<List<Transaction>> getByMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final yearMonth = '$year-${month.toString().padLeft(2, '0')}';
    final maps = await db.rawQuery(
      "$_selectWithCategory WHERE t.date LIKE '$yearMonth%' ORDER BY t.date DESC, datetime(t.created_at) DESC",
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  Future<Map<String, double>> getSummaryByMonth(int year, int month) async {
    final db = await _dbHelper.database;
    final yearMonth = '$year-${month.toString().padLeft(2, '0')}';

    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE date LIKE '$yearMonth%'
      GROUP BY type
    ''');

    double income = 0;
    double expense = 0;
    for (final row in result) {
      if (row['type'] == 'income') income = row['total'] as double;
      if (row['type'] == 'expense') expense = row['total'] as double;
    }
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Future<String> insert(Transaction transaction) async {
    final db = await _dbHelper.database;
    await db.insert('transactions', transaction.toMap(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
    return transaction.id;
  }

  Future<int> update(Transaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
