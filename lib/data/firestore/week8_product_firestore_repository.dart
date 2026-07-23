import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/week8_firestore_constants.dart';
import '../../models/sqlite_product.dart';
import 'week8_counter.dart';

class Week8ProductFirestoreRepository {
  final FirebaseFirestore _firestore;

  Week8ProductFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection(Week8FirestoreConstants.products);

  Future<int> insertProduct(SqliteProduct product) {
    return _firestore.runTransaction((transaction) async {
      final id = await nextWeek8Id(
        transaction,
        _firestore,
        Week8FirestoreConstants.productCounter,
      );
      transaction.set(
        _products.doc('$id'),
        product.copyWith(id: id).toFirestore(isCreate: true),
      );
      return id;
    });
  }

  Future<List<SqliteProduct>> getAllProducts() async {
    final result = await _products.orderBy('name').get();
    return result.docs.map(SqliteProduct.fromFirestore).toList();
  }

  Future<SqliteProduct?> getProductById(int id) async {
    final snapshot = await _products.doc('$id').get();
    return snapshot.exists ? SqliteProduct.fromFirestore(snapshot) : null;
  }

  Future<List<SqliteProduct>> getProductsByCategory(int categoryId) async {
    final result = await _products
        .where('categoryId', isEqualTo: categoryId)
        .get();
    final products = result.docs.map(SqliteProduct.fromFirestore).toList();
    products.sort((a, b) => a.name.compareTo(b.name));
    return products;
  }

  Future<void> updateProduct(SqliteProduct product) async {
    final id = product.id;
    if (id == null) throw ArgumentError('Product ID is required.');
    await _products.doc('$id').update(product.toFirestore());
  }

  Future<void> deleteProduct(int id) => _products.doc('$id').delete();
}
