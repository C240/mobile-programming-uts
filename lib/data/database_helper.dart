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
      int userId = await txn.insert('users', {
        'username': username,
        'password': password,
        'pin': pin,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      String accountNumber =
          'ID${Random().nextInt(99999999).toString().padLeft(8, '0')}';
      await txn.insert('accounts', {
        'user_id': userId,
        'accountNumber': accountNumber,
        'balance': 500000.0,
      });
      return userId;
    });
  }

  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
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
    String accountNumber =
        'ID${Random().nextInt(99999999).toString().padLeft(8, '0')}';
    return await db.insert('accounts', {
      'user_id': userId,
      'accountNumber': accountNumber,
      'balance': initialBalance,
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<int> transfer(
    String fromAccountNumber,
    String toAccountNumber,
    double amount,
    String description, {
    String? category,
  }) async {
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
      double fromBalance = (fromAccountResult.first['balance'] as num)
          .toDouble();
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

      int transactionId = await txn.insert('transactions', {
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

  Future<List<Map<String, dynamic>>> getTransactions(
    String accountNumber,
  ) async {
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

  Future<List<Map<String, dynamic>>> getAccountsByAccountNumber(
    String accountNumber,
  ) async {
    final db = await database;
    return await db.query(
      'accounts',
      where: 'accountNumber = ?',
      whereArgs: [accountNumber],
    );
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

  Future<void> updateAccountBalance(
    String accountNumber,
    double newBalance,
  ) async {
    final db = await database;
    await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'accountNumber = ?',
      whereArgs: [accountNumber],
    );
  }

  Future<int> insertTransaction({
    required String fromAccount,
    required String toAccountNumber,
    required double amount,
    String? description,
    String? category,
  }) async {
    final db = await database;
    return await db.insert('transactions', {
      'fromAccountNumber': fromAccount,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
      'description': description,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  
  Future<int> topUp(
    String accountNumber,
    double amount,
    String paymentMethod,
    String description,
  ) async {
    final db = await DatabaseHelper().database;
    return await db.transaction((txn) async {
      // Get current account balance
      var accountResult = await txn.query(
        'accounts',
        where: 'accountNumber = ?',
        whereArgs: [accountNumber],
      );

      if (accountResult.isEmpty) {
        throw Exception('Rekening tidak ditemukan');
      }

      double currentBalance = (accountResult.first['balance'] as num)
          .toDouble();
      double newBalance = currentBalance + amount;

      // Update account balance
      await txn.update(
        'accounts',
        {'balance': newBalance},
        where: 'accountNumber = ?',
        whereArgs: [accountNumber],
      );

      // Record the top-up transaction
      // For top-up, we use a special "SYSTEM" account as the source
      int transactionId = await txn.insert('transactions', {
        'fromAccountNumber': 'SYSTEM_TOPUP',
        'toAccountNumber': accountNumber,
        'amount': amount,
        'description': description,
        'category': 'Top-Up & Data',
        'timestamp': DateTime.now().toIso8601String(),
      });

      return transactionId;
    });
  }
}


Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'banking.db');
  return await openDatabase(
    path,
    version: 3, // ⬅️ CHANGE FROM 2 TO 3
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
      pin TEXT,
      email TEXT,
      phone TEXT,
      avatarUrl TEXT,
      createdAt TEXT
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
  if (oldVersion < 3) {
    // Add new user profile fields
    try {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
    } catch (e) {
      print('Column email already exists or error: $e');
    }
    try {
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
    } catch (e) {
      print('Column phone already exists or error: $e');
    }
    try {
      await db.execute('ALTER TABLE users ADD COLUMN avatarUrl TEXT');
    } catch (e) {
      print('Column avatarUrl already exists or error: $e');
    }
    try {
      await db.execute('ALTER TABLE users ADD COLUMN createdAt TEXT');
    } catch (e) {
      print('Column createdAt already exists or error: $e');
    }
  }
}


Future<int> registerUser(
  String username,
  String password,
  String pin, {
  String? email,
  String? phone,
}) async {
  final db = await database;
  return await db.transaction((txn) async {
    int userId = await txn.insert('users', {
      'username': username,
      'password': password,
      'pin': pin,
      'email': email,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    
    String accountNumber =
        'ID${Random().nextInt(99999999).toString().padLeft(8, '0')}';
    await txn.insert('accounts', {
      'user_id': userId,
      'accountNumber': accountNumber,
      'balance': 500000.0,
    });
    return userId;
  });
}

Future<bool> updateUserProfile(
  int userId, {
  String? username,
  String? email,
  String? phone,
  String? avatarUrl,
}) async {
  final db = await database;
  
  // Build update map with only non-null values
  Map<String, dynamic> updates = {};
  if (username != null) updates['username'] = username;
  if (email != null) updates['email'] = email;
  if (phone != null) updates['phone'] = phone;
  if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
  
  // If no updates, return false
  if (updates.isEmpty) return false;
  
  try {
    int count = await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
    return count > 0;
  } catch (e) {
    print('Error updating user profile: $e');
    return false;
  }
}

/// Get comprehensive user statistics
/// Returns map with account and transaction statistics
Future<Map<String, dynamic>> getUserStatistics(int userId) async {
  final db = await database;
  
  try {
    // Get user's accounts
    final accounts = await getAccounts(userId);
    
    if (accounts.isEmpty) {
      return {
        'totalAccounts': 0,
        'totalBalance': 0.0,
        'totalTransactions': 0,
        'monthlyTransactions': 0,
        'totalDebit': 0.0,
        'totalCredit': 0.0,
      };
    }
    
    double totalBalance = 0.0;
    int totalTransactions = 0;
    int monthlyTransactions = 0;
    double totalDebit = 0.0;
    double totalCredit = 0.0;
    
    final now = DateTime.now();
    
    // Process each account
    for (var acc in accounts) {
      final accountNumber = acc['accountNumber'] as String;
      totalBalance += (acc['balance'] as num).toDouble();
      
      // Get all transactions for this account
      final transactions = await db.query(
        'transactions',
        where: 'fromAccountNumber = ? OR toAccountNumber = ?',
        whereArgs: [accountNumber, accountNumber],
      );
      
      totalTransactions += transactions.length;
      
      // Calculate monthly stats and debit/credit
      for (var tx in transactions) {
        final timestamp = DateTime.parse(tx['timestamp'] as String);
        final amount = (tx['amount'] as num).toDouble();
        final isDebit = tx['fromAccountNumber'] == accountNumber;
        
        // Count monthly transactions
        if (timestamp.year == now.year && timestamp.month == now.month) {
          monthlyTransactions++;
        }
        
        // Sum debit and credit
        if (isDebit) {
          totalDebit += amount;
        } else {
          totalCredit += amount;
        }
      }
    }
    
    return {
      'totalAccounts': accounts.length,
      'totalBalance': totalBalance,
      'totalTransactions': totalTransactions,
      'monthlyTransactions': monthlyTransactions,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
    };
  } catch (e) {
    print('Error getting user statistics: $e');
    return {
      'totalAccounts': 0,
      'totalBalance': 0.0,
      'totalTransactions': 0,
      'monthlyTransactions': 0,
      'totalDebit': 0.0,
      'totalCredit': 0.0,
    };
  }
}

/// Get user profile by ID with all fields
/// Returns null if user not found
Future<User?> getUserProfile(int userId) async {
  final db = await database;
  try {
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  } catch (e) {
    print('Error getting user profile: $e');
    return null;
  }
}

/// Check if email is already registered
/// Returns true if email exists
Future<bool> isEmailRegistered(String email) async {
  final db = await database;
  try {
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  } catch (e) {
    print('Error checking email: $e');
    return false;
  }
}

/// Check if username is already taken (excluding current user)
/// Returns true if username exists for a different user
Future<bool> isUsernameAvailable(String username, {int? excludeUserId}) async {
  final db = await database;
  try {
    String whereClause = 'username = ?';
    List<dynamic> whereArgs = [username];
    
    if (excludeUserId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeUserId);
    }
    
    final result = await db.query(
      'users',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return result.isEmpty; // Available if no results
  } catch (e) {
    print('Error checking username: $e');
    return false;
  }
}