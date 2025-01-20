import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/JsonModels/users.dart';

class DatabaseHelper {
  final databaseName = "notes.db";

  String users =
      "create table users (usrId INTEGER PRIMARY KEY AUTOINCREMENT, usrEmail TEXT UNIQUE, usrPassword TEXT)";

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
      await db.execute(users);
      await db.execute(calculationsTable);
    });
  }

  Future<int> insertCalculation(Map<String, dynamic> data) async {
    final db = await initDB();
    return db.insert('calculations', data);
  }

  // Updated Login Method without hashing
  Future<bool> login(Users user) async {
    final Database db = await initDB();
    var result = await db.rawQuery(
        "SELECT * FROM users WHERE usrEmail = ? AND usrPassword = ?",
        [user.usrEmail, user.usrPassword]); // Use plain password for comparison
    return result.isNotEmpty;
  }

  // New Method to Get User Profile
  Future<Users> getUserProfile(String email) async {
    final Database db = await initDB();
    var result = await db.query(
      'users',
      where: 'usrEmail = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return Users.fromJson(result.first);
    } else {
      throw Exception('User not found');
    }
  }

  Future<int> signup(Users user) async {
    final Database db = await initDB();
    // Store the password without hashing
    return db.insert('users', user.toJson());
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

  Future<List<Users>> getAllUsers() async {
    final Database db = await initDB();
    List<Map<String, dynamic>> result = await db.query('users');
    return result.map((e) => Users.fromJson(e)).toList();
  }

  Future<int> updateUser(usrEmail, usrPassword, usrId) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update users set usrEmail = ?, usrPassword = ? where usrId = ?',
        [usrEmail, usrPassword, usrId]);
  }

  Future<int> deleteUser(int usrId) async {
    final Database db = await initDB();
    return db.delete('users', where: 'usrId = ?', whereArgs: [usrId]);
  }

  Future<List<Users>> searchUsers(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db
        .rawQuery("select * from users where usrEmail LIKE ?", ["%$keyword%"]);
    return searchResult.map((e) => Users.fromJson(e)).toList();
  }

  // New method to clear all users
  Future<void> clearAllUsers() async {
    final Database db = await initDB();
    await db.delete('users'); // Deletes all users from the table
  }
}
