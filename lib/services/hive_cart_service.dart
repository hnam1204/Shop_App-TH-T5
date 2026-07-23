import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/hive_cart_model.dart';
import '../models/hive_product_model.dart';
import '../models/sqlite_product.dart';
import '../core/database/database_constants.dart';
import '../constants/week8_firestore_constants.dart';
import '../constants/app_hive_constants.dart';

class HiveCartService {
  final Box _box = Hive.box(AppHiveConstants.cartBox);

  ValueListenable<Box<dynamic>> get listenable => _box.listenable();

  List<HiveCartModel> getCartItems() {
    if (_box.isEmpty) return [];
    return _box.values
        .map((value) {
          if (value is! Map) {
            throw StateError('Dữ liệu Cart Hive không đúng định dạng.');
          }
          return HiveCartModel.fromMap(value);
        })
        .toList(growable: false);
  }

  Future<void> addToCart(HiveProductModel product) async {
    await addSnapshot(
      sourceType: DatabaseConstants.productSourceHive,
      productId: product.id,
      productName: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
    );
  }

  Future<void> addSqliteProduct(SqliteProduct product) async {
    final id = product.id;
    if (id == null) {
      throw ArgumentError('Sản phẩm SQLite chưa có ID.');
    }
    await addSnapshot(
      sourceType: Week8FirestoreConstants.productSource,
      productId: id.toString(),
      productName: product.name,
      imageUrl: product.image ?? '',
      price: product.price,
    );
  }

  Future<void> addSnapshot({
    required String sourceType,
    required String productId,
    required String productName,
    required String imageUrl,
    required double price,
  }) async {
    if (productId.trim().isEmpty || productName.trim().isEmpty || price < 0) {
      throw ArgumentError('Thông tin sản phẩm thêm vào giỏ không hợp lệ.');
    }
    final logicalKey = '$sourceType:$productId';
    final items = getCartItems();
    final index = items.indexWhere((item) => item.logicalKey == logicalKey);
    if (index != -1) {
      final existing = items[index];
      await _box.put(
        existing.id,
        existing.copyWith(quantity: existing.quantity + 1).toMap(),
      );
      return;
    }
    final item = HiveCartModel(
      id: '${DateTime.now().microsecondsSinceEpoch}-$logicalKey',
      sourceType: sourceType,
      productId: productId,
      productName: productName.trim(),
      imageUrl: imageUrl.trim(),
      price: price,
      quantity: 1,
      addedAt: DateTime.now(),
    );
    await _box.put(item.id, item.toMap());
  }

  Future<void> updateCartProductDetails(HiveProductModel product) async {
    final items = getCartItems();
    for (final item in items) {
      if (item.sourceType == DatabaseConstants.productSourceHive &&
          item.productId == product.id) {
        final updatedItem = item.copyWith(
          productName: product.name,
          imageUrl: product.imageUrl,
          price: product.price,
        );
        await _box.put(updatedItem.id, updatedItem.toMap());
      }
    }
  }

  Future<void> increaseQuantity(String productId, {String? sourceType}) async {
    final items = getCartItems();
    final index = items.indexWhere(
      (item) =>
          item.productId == productId &&
          (sourceType == null || item.sourceType == sourceType),
    );
    if (index != -1) {
      final existingItem = items[index];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
      await _box.put(updatedItem.id, updatedItem.toMap());
    }
  }

  Future<void> decreaseQuantity(String productId, {String? sourceType}) async {
    final items = getCartItems();
    final index = items.indexWhere(
      (item) =>
          item.productId == productId &&
          (sourceType == null || item.sourceType == sourceType),
    );
    if (index != -1) {
      final existingItem = items[index];
      if (existingItem.quantity > 1) {
        final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        );
        await _box.put(updatedItem.id, updatedItem.toMap());
      } else {
        await _box.delete(existingItem.id);
      }
    }
  }

  Future<void> removeFromCart(String productId, {String? sourceType}) async {
    final items = getCartItems();
    final index = items.indexWhere(
      (item) =>
          item.productId == productId &&
          (sourceType == null || item.sourceType == sourceType),
    );
    if (index != -1) {
      await _box.delete(items[index].id);
    }
  }

  Future<void> updateQuantity(
    String productId,
    int quantity, {
    required String sourceType,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(productId, sourceType: sourceType);
      return;
    }
    final items = getCartItems();
    final index = items.indexWhere(
      (item) => item.productId == productId && item.sourceType == sourceType,
    );
    if (index == -1) return;
    final item = items[index];
    await _box.put(item.id, item.copyWith(quantity: quantity).toMap());
  }

  Future<void> clearCart() async {
    await _box.clear();
  }

  double getTotalAmount() {
    final items = getCartItems();
    return items.fold(0, (total, item) => total + item.totalPrice);
  }

  int getTotalQuantity() {
    final items = getCartItems();
    return items.fold(0, (total, item) => total + item.quantity);
  }
}
