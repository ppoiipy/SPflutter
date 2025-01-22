import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final databaseName = "app_database.db";

  final String usersTable = '''
  CREATE TABLE users (
    usrId INTEGER PRIMARY KEY AUTOINCREMENT,
    usrEmail TEXT UNIQUE,
    usrPassword TEXT
  );
  ''';

  final String calculationsTable = '''
  CREATE TABLE calculations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    gender TEXT,
    age INTEGER,
    height REAL,
    weight REAL,
    bmi REAL,
    bmr REAL,
    tdee REAL
  );
  ''';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(usersTable);
      await db.execute(calculationsTable);
    });
  }

  Future<int> signup(String email, String password) async {
    final db = await initDB();
    return db.insert('users', {
      'usrEmail': email,
      'usrPassword': password,
    });
  }

  Future<bool> login(String email, String password) async {
    final db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrEmail = ? AND usrPassword = ?",
        [email, password]);
    return result.isNotEmpty;
  }

  Future<bool> checkEmailExists(String email) async {
    final db = await initDB();
    final result = await db.query(
      'users',
      where: 'usrEmail = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<int> insertCalculation(Map<String, dynamic> data) async {
    final db = await initDB();
    return db.insert('calculations', data);
  }
}
