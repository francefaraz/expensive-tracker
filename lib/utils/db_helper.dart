import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            title TEXT,
            amount REAL,
            paymentMethod TEXT,
            category TEXT,
            date TEXT,
            note TEXT,
            tag TEXT,
            isCreditCard INTEGER DEFAULT 0,
            creditCardName TEXT,
            isPaidOff INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  static Future<int> insertTransaction(TransactionModel txn) async {
    final db = await database;
    return await db.insert('transactions', txn.toMap());
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateTransaction(TransactionModel txn) async {
    final db = await database;
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  // Get only credit card transactions
  static Future<List<TransactionModel>> getCreditCardTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'isCreditCard = ?', 
      whereArgs: [1],
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  // Get transactions that affect main balance (exclude unpaid credit card transactions)
  static Future<List<TransactionModel>> getMainBalanceTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'isCreditCard = 0 OR (isCreditCard = 1 AND isPaidOff = 1)', 
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  // Get unpaid credit card debt
  static Future<double> getCreditCardDebt() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'isCreditCard = ? AND isPaidOff = ?', 
      whereArgs: [1, 0]
    );
    
    double totalDebt = 0.0;
    for (var map in maps) {
      final txn = TransactionModel.fromMap(map);
      if (txn.type == 'expense') {
        totalDebt += txn.amount;
      } else {
        totalDebt -= txn.amount; // Income reduces debt
      }
    }
    return totalDebt;
  }

  // Mark credit card transaction as paid off
  static Future<int> markCreditCardPaid(int id) async {
    final db = await database;
    return await db.update(
      'transactions',
      {'isPaidOff': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get credit card transactions by card name
  static Future<List<TransactionModel>> getCreditCardTransactionsByCard(String cardName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions', 
      where: 'isCreditCard = ? AND creditCardName = ?', 
      whereArgs: [1, cardName],
      orderBy: 'date DESC'
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }
}
