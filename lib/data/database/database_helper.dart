import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('myfinance.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // สร้างตาราง categories
    await db.execute('''
      CREATE TABLE categories (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        name      TEXT    NOT NULL,
        type      TEXT    NOT NULL,
        icon      TEXT    NOT NULL,
        color     TEXT    NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // สร้างตาราง transactions
    await db.execute('''
      CREATE TABLE transactions (
        id          TEXT PRIMARY KEY,
        amount      REAL    NOT NULL,
        type        TEXT    NOT NULL,
        category_id INTEGER NOT NULL,
        note        TEXT,
        date        TEXT    NOT NULL,
        created_at  TEXT    NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // Seed หมวดหมู่เริ่มต้น
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final categories = [
      // รายรับ
      {'name': 'เงินเดือน',    'type': 'income',  'icon': '💼', 'color': '4CAF50', 'is_default': 1},
      {'name': 'รายได้อื่นๆ',  'type': 'income',  'icon': '💰', 'color': '8BC34A', 'is_default': 1},
      // รายจ่าย
      {'name': 'อาหาร',        'type': 'expense', 'icon': '🍜', 'color': 'FF6B6B', 'is_default': 1},
      {'name': 'เดินทาง',      'type': 'expense', 'icon': '🚗', 'color': 'FF9800', 'is_default': 1},
      {'name': 'ช้อปปิ้ง',    'type': 'expense', 'icon': '🛍️', 'color': 'E91E63', 'is_default': 1},
      {'name': 'ค่าบ้าน',      'type': 'expense', 'icon': '🏠', 'color': '9C27B0', 'is_default': 1},
      {'name': 'สุขภาพ',       'type': 'expense', 'icon': '💊', 'color': '00BCD4', 'is_default': 1},
      {'name': 'บันเทิง',      'type': 'expense', 'icon': '🎮', 'color': '3F51B5', 'is_default': 1},
    ];

    for (final cat in categories) {
      await db.insert('categories', cat);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}