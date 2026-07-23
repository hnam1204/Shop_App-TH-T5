import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/categoryfb_model.dart';

class CategoryFbService {
  final CollectionReference<Map<String, dynamic>> _categories =
      FirebaseFirestore.instance.collection('categories');

  Stream<List<CategoryFbModel>> getCategories() {
    return _categories
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CategoryFbModel.fromDoc).toList());
  }

  Future<void> addCategory({
    required String name,
    required String imageUrl,
  }) async {
    final doc = _categories.doc();
    await doc.set({
      'id': doc.id,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String imageUrl,
  }) {
    return _categories.doc(id).update({
      'name': name,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String id) {
    return _categories.doc(id).delete();
  }
}
