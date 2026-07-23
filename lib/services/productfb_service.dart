import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/productfb_model.dart';

class ProductFbService {
  final CollectionReference<Map<String, dynamic>> _products = FirebaseFirestore
      .instance
      .collection('products');

  Stream<List<ProductFbModel>> getProducts() {
    return _products
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ProductFbModel.fromDoc).toList());
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String categoryId,
    required String categoryName,
    required String imageUrl,
    required bool isAvailable,
  }) async {
    final doc = _products.doc();
    await doc.set({
      'id': doc.id,
      'name': name,
      'price': price,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String description,
    required String categoryId,
    required String categoryName,
    required String imageUrl,
    required bool isAvailable,
  }) {
    return _products.doc(id).update({
      'name': name,
      'price': price,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String id) {
    return _products.doc(id).delete();
  }
}
