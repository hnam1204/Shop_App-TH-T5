import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../../models/sqlite_product.dart';

class ProductSqliteDataSource {
  final DatabaseHelper _databaseHelper;

  ProductSqliteDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<int> insertProduct(SqliteProduct product) async {
    final db = await _databaseHelper.database;
    return db.insert(DatabaseConstants.productTable, product.toInsertMap());
  }

  Future<List<SqliteProduct>> getAllProducts() {
    return _queryProducts();
  }

  Future<SqliteProduct?> getProductById(int id) async {
    final products = await _queryProducts(
      where: 'p.${DatabaseConstants.id} = ?',
      whereArgs: [id],
      limit: 1,
    );
    return products.isEmpty ? null : products.first;
  }

  Future<List<SqliteProduct>> getProductsByCategory(int categoryId) {
    return _queryProducts(
      where: 'p.${DatabaseConstants.categoryId} = ?',
      whereArgs: [categoryId],
    );
  }

  Future<int> updateProduct(SqliteProduct product) async {
    final id = product.id;
    if (id == null) throw ArgumentError('Product ID is required.');
    final db = await _databaseHelper.database;
    return db.update(
      DatabaseConstants.productTable,
      product.toInsertMap(),
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await _databaseHelper.database;
    return db.delete(
      DatabaseConstants.productTable,
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [id],
    );
  }

  Future<bool> productNameExists(String name, {int? excludingId}) async {
    final db = await _databaseHelper.database;
    final where = StringBuffer('LOWER(${DatabaseConstants.name}) = LOWER(?)');
    final args = <Object?>[name.trim()];
    if (excludingId != null) {
      where.write(' AND ${DatabaseConstants.id} <> ?');
      args.add(excludingId);
    }
    final rows = await db.query(
      DatabaseConstants.productTable,
      columns: [DatabaseConstants.id],
      where: where.toString(),
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<bool> categoryExists(int categoryId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseConstants.categoryTable,
      columns: [DatabaseConstants.id],
      where: '${DatabaseConstants.id} = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<SqliteProduct>> _queryProducts({
    String? where,
    List<Object?>? whereArgs,
    int? limit,
  }) async {
    final db = await _databaseHelper.database;
    final sql = StringBuffer('''
      SELECT
        p.${DatabaseConstants.id},
        p.${DatabaseConstants.name},
        p.${DatabaseConstants.price},
        p.${DatabaseConstants.image},
        p.${DatabaseConstants.description},
        p.${DatabaseConstants.categoryId},
        c.${DatabaseConstants.name} AS ${DatabaseConstants.categoryName}
      FROM ${DatabaseConstants.productTable} p
      INNER JOIN ${DatabaseConstants.categoryTable} c
        ON c.${DatabaseConstants.id} = p.${DatabaseConstants.categoryId}
    ''');
    if (where != null) sql.write(' WHERE $where');
    sql.write(' ORDER BY p.${DatabaseConstants.id} DESC');
    if (limit != null) sql.write(' LIMIT $limit');
    final rows = await db.rawQuery(sql.toString(), whereArgs);
    return rows.map(SqliteProduct.fromMap).toList(growable: false);
  }
}
