// lib/data/database_helper.dart

import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'banking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        pin TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        accountNumber TEXT UNIQUE,
        balance REAL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromAccountNumber TEXT,
        toAccountNumber TEXT,
        amount REAL,
        description TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Register Function
  Future<int> registerUser(String username, String password, String pin) async {
    final db = await database;
    return await db.transaction((txn) async {
      int userId = await txn.insert(
        'users',
        {
          'username': username,
          'password': password,
          'pin': pin,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      String accountNumber = 'ID' + Random().nextInt(99999999).toString().padLeft(8, '0');
      await txn.insert(
        'accounts',
        {
          'user_id': userId,
          'accountNumber': accountNumber,
          'balance': 500000.0,
        });
        return userId;
    });
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}