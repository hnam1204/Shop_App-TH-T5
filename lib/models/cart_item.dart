import 'app_product_snapshot.dart';

class CartItem {
  final AppProductSnapshot product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  String get key => product.compositeKey;
  double get subtotal => product.price * quantity;

  factory CartItem.fromMap(Map<dynamic, dynamic> map) => CartItem(
    product: AppProductSnapshot.fromMap(
      map['product'] is Map ? map['product'] as Map : map,
    ),
    quantity: map['quantity'] is num ? (map['quantity'] as num).toInt() : 1,
  );

  Map<String, dynamic> toMap() => {
    'product': product.toMap(),
    'quantity': quantity,
  };

  CartItem copyWith({AppProductSnapshot? product, int? quantity}) => CartItem(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );
}
