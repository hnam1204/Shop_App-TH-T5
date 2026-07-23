import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_product_model.dart';

class HiveProductService {
  final Box _box = Hive.box('products_hive');

  List<HiveProductModel> getAllProducts() {
    try {
      if (_box.isEmpty) return [];
      return _box.values.map((e) {
        if (e is Map) {
          return HiveProductModel.fromMap(e);
        }
        return HiveProductModel.fromMap(Map<String, dynamic>.from(e as Map));
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<void> addProduct(HiveProductModel product) async {
    try {
      await _box.put(product.id, product.toMap());
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(HiveProductModel product) async {
    try {
      await _box.put(product.id, product.toMap());
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  List<HiveProductModel> searchProducts(String keyword) {
    try {
      if (keyword.isEmpty) return getAllProducts();
      final lowerKeyword = keyword.toLowerCase();
      return getAllProducts()
          .where((p) => p.name.toLowerCase().contains(lowerKeyword))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<void> clearAllProducts() async {
    try {
      await _box.clear();
    } catch (e) {
      print('Error clearing products: $e');
    }
  }

  Future<void> seedSampleProductsIfEmpty() async {
    try {
      if (_box.isNotEmpty) return;
      final samples = [
        HiveProductModel(
          id: '${DateTime.now().millisecondsSinceEpoch}1',
          name: 'Cà phê sữa',
          description: 'Cà phê sữa đá thơm ngon truyền thống Việt Nam',
          category: 'Đồ uống',
          price: 25000,
          imageUrl:
              'https://images.unsplash.com/photo-1611162458324-aae1eb4129a4?q=80&w=600&auto=format&fit=crop',
          stock: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HiveProductModel(
          id: '${DateTime.now().millisecondsSinceEpoch}2',
          name: 'Trà đào',
          description: 'Trà đào cam sả giải nhiệt mùa hè',
          category: 'Đồ uống',
          price: 35000,
          imageUrl:
              'https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=600&auto=format&fit=crop',
          stock: 50,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HiveProductModel(
          id: '${DateTime.now().millisecondsSinceEpoch}3',
          name: 'Bánh mì',
          description: 'Bánh mì thịt chả truyền thống giòn rụm',
          category: 'Đồ ăn',
          price: 20000,
          imageUrl:
              'https://images.unsplash.com/photo-1627308595229-78308709335a?q=80&w=600&auto=format&fit=crop',
          stock: 200,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HiveProductModel(
          id: '${DateTime.now().millisecondsSinceEpoch}4',
          name: 'Cơm gà',
          description: 'Cơm gà xối mỡ da giòn',
          category: 'Đồ ăn',
          price: 45000,
          imageUrl:
              'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?q=80&w=600&auto=format&fit=crop',
          stock: 30,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        HiveProductModel(
          id: '${DateTime.now().millisecondsSinceEpoch}5',
          name: 'Nước suối',
          description: 'Nước suối tinh khiết đóng chai',
          category: 'Đồ uống',
          price: 10000,
          imageUrl:
              'https://images.unsplash.com/photo-1523362628745-0c100150b504?q=80&w=600&auto=format&fit=crop',
          stock: 500,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      for (var p in samples) {
        await addProduct(p);
      }
    } catch (e) {
      print('Error seeding products: $e');
    }
  }
}
