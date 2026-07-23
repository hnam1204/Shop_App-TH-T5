import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'database_constants.dart';

class UnsupportedDatabasePlatformException implements Exception {
  final String message;

  const UnsupportedDatabasePlatformException(this.message);

  @override
  String toString() => message;
}

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;
  Future<Database>? _openingDatabase;

  Future<Database> get database async {
    if (kIsWeb) {
      throw const UnsupportedDatabasePlatformException(
        'SQLite không được hỗ trợ trên Flutter Web.',
      );
    }
    final current = _database;
    if (current != null && current.isOpen) return current;

    final opening = _openingDatabase;
    if (opening != null) return opening;

    final future = _initDatabase();
    _openingDatabase = future;
    try {
      final opened = await future;
      _database = opened;
      return opened;
    } finally {
      _openingDatabase = null;
    }
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(
      databasesPath,
      DatabaseConstants.databaseName,
    );
    return openDatabase(
      databasePath,
      version: DatabaseConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    _createCategoryAndProduct(batch);
    if (version >= 2) {
      _createPaymentTablesAndIndexes(batch);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      final batch = db.batch();
      _createPaymentTablesAndIndexes(batch);
      await batch.commit(noResult: true);
    }
  }

  void _createCategoryAndProduct(Batch batch) {
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.categoryTable} (
        ${DatabaseConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.name} TEXT NOT NULL COLLATE NOCASE UNIQUE,
        ${DatabaseConstants.image} TEXT
      )
    ''');
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.productTable} (
        ${DatabaseConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.name} TEXT NOT NULL,
        ${DatabaseConstants.price} REAL NOT NULL
          CHECK(${DatabaseConstants.price} >= 0),
        ${DatabaseConstants.image} TEXT,
        ${DatabaseConstants.description} TEXT NOT NULL DEFAULT '',
        ${DatabaseConstants.categoryId} INTEGER NOT NULL,
        FOREIGN KEY(${DatabaseConstants.categoryId})
          REFERENCES ${DatabaseConstants.categoryTable}(${DatabaseConstants.id})
          ON DELETE RESTRICT
      )
    ''');
  }

  void _createPaymentTablesAndIndexes(Batch batch) {
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.paymentTable} (
        ${DatabaseConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.totalAmount} REAL NOT NULL
          CHECK(${DatabaseConstants.totalAmount} >= 0),
        ${DatabaseConstants.paymentMethod} TEXT NOT NULL DEFAULT
          '${DatabaseConstants.paymentMethodCash}',
        ${DatabaseConstants.status} TEXT NOT NULL DEFAULT
          '${DatabaseConstants.paymentStatusCompleted}',
        ${DatabaseConstants.customerId} TEXT,
        ${DatabaseConstants.customerName} TEXT,
        ${DatabaseConstants.note} TEXT,
        ${DatabaseConstants.createdAt} TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.paymentDetailTable} (
        ${DatabaseConstants.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.paymentId} INTEGER NOT NULL,
        ${DatabaseConstants.productSource} TEXT NOT NULL,
        ${DatabaseConstants.productId} TEXT NOT NULL,
        ${DatabaseConstants.productName} TEXT NOT NULL,
        ${DatabaseConstants.productImage} TEXT,
        ${DatabaseConstants.quantity} INTEGER NOT NULL
          CHECK(${DatabaseConstants.quantity} > 0),
        ${DatabaseConstants.unitPrice} REAL NOT NULL
          CHECK(${DatabaseConstants.unitPrice} >= 0),
        ${DatabaseConstants.subtotal} REAL NOT NULL
          CHECK(${DatabaseConstants.subtotal} >= 0),
        FOREIGN KEY(${DatabaseConstants.paymentId})
          REFERENCES ${DatabaseConstants.paymentTable}(${DatabaseConstants.id})
          ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE INDEX ${DatabaseConstants.productCategoryIndex}
      ON ${DatabaseConstants.productTable}(${DatabaseConstants.categoryId})
    ''');
    batch.execute('''
      CREATE INDEX ${DatabaseConstants.paymentCreatedAtIndex}
      ON ${DatabaseConstants.paymentTable}(${DatabaseConstants.createdAt})
    ''');
    batch.execute('''
      CREATE INDEX ${DatabaseConstants.paymentDetailPaymentIndex}
      ON ${DatabaseConstants.paymentDetailTable}(${DatabaseConstants.paymentId})
    ''');
  }

  Future<T> transaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<void> close() async {
    final current = _database;
    _database = null;
    if (current != null && current.isOpen) {
      await current.close();
    }
  }
}
