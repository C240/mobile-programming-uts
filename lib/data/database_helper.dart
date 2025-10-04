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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        category TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT');
    }
  }

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
      String accountNumber = 'ID${Random().nextInt(99999999).toString().padLeft(8, '0')}';
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

  Future<List<Map<String, dynamic>>> getAccounts(int userId) async {
    final db = await database;
    var result = await db.query(
      'accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id ASC',
    );
    return result;
  }

  Future<int> createAccount(int userId, double initialBalance) async {
    final db = await database;
    String accountNumber = 'ID${Random().nextInt(99999999).toString().padLeft(8, '0')}';
    return await db.insert(
      'accounts',
      {
        'user_id': userId,
        'accountNumber': accountNumber,
        'balance': initialBalance,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> transfer(
    String fromAccountNumber,
    String toAccountNumber,
    double amount,
    String description,
    {String? category}
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
      double fromBalance = (fromAccountResult.first['balance'] as num).toDouble();
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
      double toBalance = (toAccountResult.first['balance'] as num).toDouble();
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
          'category': category,
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
  Future<User?> getUserById(int id) async {
    final db = await database;
    var result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }
  Future<User?> getUserByAccountNumber(String accountNumber) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT u.id, u.username FROM users u INNER JOIN accounts a ON a.user_id = u.id WHERE a.accountNumber = ?',
      [accountNumber],
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }
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