import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/week8_firestore_constants.dart';
import '../../models/sqlite_category.dart';
import 'week8_counter.dart';

class Week8CategoryFirestoreRepository {
  final FirebaseFirestore _firestore;

  Week8CategoryFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection(Week8FirestoreConstants.categories);

  Future<int> insertCategory(SqliteCategory category) {
    return _firestore.runTransaction((transaction) async {
      final id = await nextWeek8Id(
        transaction,
        _firestore,
        Week8FirestoreConstants.categoryCounter,
      );
      transaction.set(
        _categories.doc('$id'),
        category.copyWith(id: id).toFirestore(isCreate: true),
      );
      return id;
    });
  }

  Future<List<SqliteCategory>> getAllCategories() async {
    final result = await _categories.orderBy('name').get();
    return result.docs.map(SqliteCategory.fromFirestore).toList();
  }

  Future<SqliteCategory?> getCategoryById(int id) async {
    final snapshot = await _categories.doc('$id').get();
    return snapshot.exists ? SqliteCategory.fromFirestore(snapshot) : null;
  }

  Future<void> updateCategory(SqliteCategory category) async {
    final id = category.id;
    if (id == null) throw ArgumentError('Category ID is required.');
    final oldSnapshot = await _categories.doc('$id').get();
    if (!oldSnapshot.exists) throw StateError('Category not found.');
    final oldName = oldSnapshot.data()?['name']?.toString();
    await _categories.doc('$id').update(category.toFirestore());
    if (oldName != category.name) {
      await _updateProductCategoryNames(id, category.name);
    }
  }

  Future<void> _updateProductCategoryNames(int categoryId, String name) async {
    final products = await _firestore
        .collection(Week8FirestoreConstants.products)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    for (var start = 0; start < products.docs.length; start += 450) {
      final batch = _firestore.batch();
      for (final doc in products.docs.skip(start).take(450)) {
        batch.update(doc.reference, {
          'categoryName': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> deleteCategory(int id) => _categories.doc('$id').delete();

  Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    final normalized = name.trim().toLowerCase();
    final result = await _categories
        .where('normalizedName', isEqualTo: normalized)
        .limit(2)
        .get();
    return result.docs.any((doc) => doc.id != '$excludeId');
  }

  Future<bool> categoryHasProducts(int categoryId) async {
    final result = await _firestore
        .collection(Week8FirestoreConstants.products)
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }
}
