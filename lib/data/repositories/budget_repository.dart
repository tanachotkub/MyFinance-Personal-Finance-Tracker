import 'package:sqflite/sqflite.dart' as sqflite;
import '../database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Budget>> getBudgetsWithSpent(int year, int month) async {
    final db = await _dbHelper.database;
    final yearMonth = '$year-${month.toString().padLeft(2, '0')}';

    final maps = await db.rawQuery('''
  SELECT 
    b.*,
    c.name  AS category_name,
    c.icon  AS category_icon,
    c.color AS category_color,
    CAST(COALESCE(SUM(t.amount), 0) AS REAL) AS spent  -- ← เพิ่ม CAST
  FROM budgets b
  LEFT JOIN categories c ON b.category_id = c.id
  LEFT JOIN transactions t 
    ON t.category_id = b.category_id 
    AND t.type = 'expense'
    AND t.date LIKE '$yearMonth%'
  GROUP BY b.id
  ORDER BY b.category_id
''');

    return maps.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> setBudget(int categoryId, double amount) async {
    final db = await _dbHelper.database;
    await db.insert(
      'budgets',
      {'category_id': categoryId, 'amount': amount},
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBudget(int categoryId) async {
    final db = await _dbHelper.database;
    await db
        .delete('budgets', where: 'category_id = ?', whereArgs: [categoryId]);
  }
}
