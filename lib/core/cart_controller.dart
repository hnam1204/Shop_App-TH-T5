import 'package:flutter/foundation.dart';

import '../models/product.dart';

// Legacy Week 01-07 in-memory cart. Week 09 UI uses cartProvider and
// persists through the existing cart_hive box. Kept only for reference.

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}

final ValueNotifier<List<CartItem>> cartNotifier =
    ValueNotifier<List<CartItem>>(<CartItem>[]);

void addProductToCart(Product product) {
  final items = List<CartItem>.from(cartNotifier.value);
  final index = items.indexWhere((item) => item.product.id == product.id);

  if (index == -1) {
    items.add(CartItem(product: product, quantity: 1));
  } else {
    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + 1);
  }

  cartNotifier.value = items;
}

void removeProductFromCart(int productId) {
  cartNotifier.value = cartNotifier.value
      .where((item) => item.product.id != productId)
      .toList();
}

void updateCartQuantity(int productId, int quantity) {
  if (quantity <= 0) {
    removeProductFromCart(productId);
    return;
  }

  cartNotifier.value = cartNotifier.value.map((item) {
    if (item.product.id != productId) return item;
    return item.copyWith(quantity: quantity);
  }).toList();
}

int cartItemCount(List<CartItem> items) {
  return items.fold(0, (total, item) => total + item.quantity);
}

double cartTotal(List<CartItem> items) {
  return items.fold(
    0,
    (total, item) => total + item.product.price * item.quantity,
  );
}
