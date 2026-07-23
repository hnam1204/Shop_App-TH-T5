import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_product_snapshot.dart';
import '../models/cart_item.dart';
import '../services/hive_cart_service.dart';

class CartState {
  final List<CartItem> items;
  final bool isSaving;
  final String? errorMessage;

  const CartState({
    this.items = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  int get totalQuantity =>
      items.fold(0, (total, item) => total + item.quantity);
  double get totalAmount =>
      items.fold(0, (total, item) => total + item.subtotal);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    bool? isSaving,
    String? errorMessage,
  }) => CartState(
    items: items ?? this.items,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: errorMessage,
  );
}

class CartNotifier extends AsyncNotifier<CartState> {
  late final HiveCartService _service;
  Future<void> _queue = Future.value();

  @override
  Future<CartState> build() async {
    _service = HiveCartService();
    return _readHive();
  }

  CartState _readHive() {
    final items = _service
        .getCartItems()
        .where((item) => item.quantity > 0 && item.price >= 0)
        .map(
          (item) => CartItem(
            product: AppProductSnapshot(
              sourceType: item.sourceType,
              productId: item.productId,
              name: item.productName,
              image: item.imageUrl,
              price: item.price,
            ),
            quantity: item.quantity,
          ),
        )
        .toList(growable: false);
    return CartState(items: items);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => _readHive());
  }

  Future<void> addProduct(AppProductSnapshot product) => _serialized(() async {
    _validate(product);
    await _service.addSnapshot(
      sourceType: product.sourceType,
      productId: product.productId,
      productName: product.name,
      imageUrl: product.image ?? '',
      price: product.price,
    );
  });

  Future<void> increaseQuantity(String key) => _change(key, 1);
  Future<void> decreaseQuantity(String key) => _change(key, -1);

  Future<void> _change(String key, int delta) => _serialized(() async {
    final item = _find(key);
    await _service.updateQuantity(
      item.product.productId,
      item.quantity + delta,
      sourceType: item.product.sourceType,
    );
  });

  Future<void> updateQuantity(String key, int quantity) =>
      _serialized(() async {
        final item = _find(key);
        await _service.updateQuantity(
          item.product.productId,
          quantity,
          sourceType: item.product.sourceType,
        );
      });

  Future<void> removeItem(String key) => _serialized(() async {
    final item = _find(key);
    await _service.removeFromCart(
      item.product.productId,
      sourceType: item.product.sourceType,
    );
  });

  Future<void> clearCart() => _serialized(_service.clearCart);

  bool containsProduct(String key) =>
      state.value?.items.any((item) => item.key == key) ?? false;

  int quantityOf(String key) {
    for (final item in state.value?.items ?? const <CartItem>[]) {
      if (item.key == key) return item.quantity;
    }
    return 0;
  }

  CartItem _find(String key) =>
      state.requireValue.items.firstWhere((item) => item.key == key);

  void _validate(AppProductSnapshot product) {
    if (product.productId.trim().isEmpty ||
        product.name.trim().isEmpty ||
        !product.price.isFinite ||
        product.price < 0) {
      throw ArgumentError('Thông tin sản phẩm không hợp lệ.');
    }
  }

  Future<void> _serialized(Future<void> Function() operation) {
    final result = _queue.then((_) async {
      final previous = state.value ?? const CartState();
      state = AsyncData(previous.copyWith(isSaving: true));
      try {
        await operation();
        state = AsyncData(_readHive());
      } catch (error, stackTrace) {
        state = AsyncData(
          previous.copyWith(isSaving: false, errorMessage: error.toString()),
        );
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _queue = result.catchError((_) {});
    return result;
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

final cartItemsProvider = Provider<List<CartItem>>(
  (ref) => ref
      .watch(cartProvider)
      .when(
        data: (value) => value.items,
        error: (_, _) => const [],
        loading: () => const [],
      ),
);
final cartTotalQuantityProvider = Provider<int>(
  (ref) => ref
      .watch(cartProvider)
      .when(
        data: (value) => value.totalQuantity,
        error: (_, _) => 0,
        loading: () => 0,
      ),
);
final cartTotalAmountProvider = Provider<double>(
  (ref) => ref
      .watch(cartProvider)
      .when(
        data: (value) => value.totalAmount,
        error: (_, _) => 0,
        loading: () => 0,
      ),
);
final cartIsEmptyProvider = Provider<bool>(
  (ref) => ref.watch(cartTotalQuantityProvider) == 0,
);
