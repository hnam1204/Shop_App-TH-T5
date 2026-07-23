import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../../models/sqlite_category.dart';

class CategorySqliteDataSource {
  final DatabaseHelper _databaseHelper;

  CategorySqliteDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<int> insertCategory(SqliteCategory category) async {
    final db = await _databaseHelper.database;
    return db.insert(
      DatabaseConstants.categoryTable,
      category.toInsertMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<SqliteCategory>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseConstants.categoryTable,
      orderBy: '${DatabaseConstants.name} COLLATE NOCASE ASC',
    );
    return rows.map(SqliteCategory.fromMap).toList(growable: false);
  }

  Future<SqliteCategory?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseConstants.categoryTable,
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : SqliteCategory.fromMap(rows.first);
  }

  Future<int> updateCategory(SqliteCategory category) async {
    final id = category.id;
    if (id == null) throw ArgumentError('Category ID is required.');
    final db = await _databaseHelper.database;
    return db.update(
      DatabaseConstants.categoryTable,
      category.toInsertMap(),
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    return db.delete(
      DatabaseConstants.categoryTable,
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> categoryNameExists(String name, {int? excludingId}) async {
    final db = await _databaseHelper.database;
    final where = StringBuffer('LOWER(${DatabaseConstants.name}) = LOWER(?)');
    final args = <Object?>[name.trim()];
    if (excludingId != null) {
      where.write(' AND ${DatabaseConstants.id} <> ?');
      args.add(excludingId);
    }
    final result = await db.query(
      DatabaseConstants.categoryTable,
      columns: [DatabaseConstants.id],
      where: where.toString(),
      whereArgs: args,
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> categoryHasProducts(int categoryId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      DatabaseConstants.productTable,
      columns: [DatabaseConstants.id],
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
