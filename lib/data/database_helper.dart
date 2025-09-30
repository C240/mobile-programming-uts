// lib/data/database_helper.dart

import 'dart:math';
import 'package:mobile_programming_uts/models/user_model.dart';
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

  Future<Map<String, dynamic>?> getAccount(int userId) async {
    final db = await database;
    var result = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> transfer(
    String fromAccountNumber,
    String toAccountNumber,
    double amount,
    String description,
  ) async {
    final db = await database;
    return await db.transaction((txn) async {
      var fromAccountResult = await txn.query(
        'accounts',
        where: 'accountNumber = ?',
        whereArgs: [fromAccountNumber],
      );
      if (fromAccountResult.isEmpty) {
        throw Exception('Rekening pengirim tidak ditemukan');
      }
      double fromBalance = fromAccountResult.first['balance'] as double;
      if (fromBalance < amount) {
        throw Exception('Saldo tidak mencukupi');
      }

      double newFromBalance = fromBalance - amount;
      await txn.update(
        'accounts',
        {'balance': newFromBalance},
        where: 'accountNumber = ?',
        whereArgs: [fromAccountNumber],
      );

      var toAccountResult = await txn.query(
        'accounts',
        where: 'accountNumber = ?',
        whereArgs: [toAccountNumber],
      );
      if (toAccountResult.isEmpty) {
        throw Exception('Rekening tujuan tidak ditemukan');
      }
      double toBalance = toAccountResult.first['balance'] as double;
      double newToBalance = toBalance + amount;
      await txn.update(
        'accounts',
        {'balance': newToBalance},
        where: 'accountNumber = ?',
        whereArgs: [toAccountNumber],
      );

      int transactionId = await txn.insert(
        'transactions',
        {
          'fromAccountNumber': fromAccountNumber,
          'toAccountNumber': toAccountNumber,
          'amount': amount,
          'description': description,
          'timestamp': DateTime.now().toIso8601String(),
        });
      return transactionId;
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions(String accountNumber) async {
    final db = await database;
    var result = await db.query(
      'transactions',
      where: 'fromAccountNumber = ? OR toAccountNumber = ?',
      whereArgs: [accountNumber, accountNumber],
      orderBy: 'timestamp DESC',
    );
    return result;
  }

  Future<bool> verifyPin(int userId, String pin) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'id = ? AND pin = ?',
      whereArgs: [userId, pin],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await database;
    var result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  
  // --- FUNGSI YANG HILANG (getUserById) ---
  Future<User?> getUserById(int id) async {
    final db = await database;
    var result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
  
  // --- FUNGSI YANG HILANG (updatePin) ---
  Future<bool> updatePin(int userId, String oldPin, String newPin) async {
    final db = await database;
    
    var result = await db.query(
      'users',
      where: 'id = ? AND pin = ?',
      whereArgs: [userId, oldPin],
    );

    if (result.isNotEmpty) {
      int count = await db.update(
        'users',
        {'pin': newPin},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    }
    
    return false;
  }
}