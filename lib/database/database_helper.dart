import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'balance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE balance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            capital REAL
          )
        ''');
      },
    );
  }

  Future<void> insertCapital(double capital) async {
    final db = await database;
    await db.insert(
      'balance',
      {'capital': capital},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<double> getCapital() async {
    final db = await database;
    final result = await db.query('balance');
    if (result.isNotEmpty) {
      return result.first['capital'] as double;
    }
    return 0.0;
  }
}
