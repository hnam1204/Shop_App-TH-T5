import 'hive_product_model.dart';
import 'product.dart';
import 'productfb_model.dart';
import 'sqlite_product.dart';

class AppProductSnapshot {
  final String sourceType;
  final String productId;
  final String name;
  final String? image;
  final double price;
  final String? description;
  final String? categoryName;

  const AppProductSnapshot({
    required this.sourceType,
    required this.productId,
    required this.name,
    this.image,
    required this.price,
    this.description,
    this.categoryName,
  });

  String get compositeKey => '$sourceType:$productId';

  factory AppProductSnapshot.fromApi(Product product) => AppProductSnapshot(
    sourceType: 'dummyjson',
    productId: '${product.id}',
    name: product.title,
    image: product.thumbnail,
    price: product.price,
    description: product.description,
    categoryName: product.category,
  );

  factory AppProductSnapshot.fromFirebase(ProductFbModel product) =>
      AppProductSnapshot(
        sourceType: 'firebase',
        productId: product.id,
        name: product.name,
        image: product.imageUrl,
        price: product.price,
        description: product.description,
        categoryName: product.categoryName,
      );

  factory AppProductSnapshot.fromHive(HiveProductModel product) =>
      AppProductSnapshot(
        sourceType: 'hive',
        productId: product.id,
        name: product.name,
        image: product.imageUrl,
        price: product.price,
        description: product.description,
        categoryName: product.category,
      );

  factory AppProductSnapshot.fromWeek8(SqliteProduct product) =>
      AppProductSnapshot(
        sourceType: 'week8_firestore',
        productId: '${product.id}',
        name: product.name,
        image: product.image,
        price: product.price,
        description: product.description,
        categoryName: product.categoryName,
      );

  factory AppProductSnapshot.fromMap(Map<dynamic, dynamic> map) =>
      AppProductSnapshot(
        sourceType: map['sourceType']?.toString() ?? '',
        productId: map['productId']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        image: _nullable(map['image']),
        price: map['price'] is num ? (map['price'] as num).toDouble() : 0,
        description: _nullable(map['description']),
        categoryName: _nullable(map['categoryName']),
      );

  Map<String, dynamic> toMap() => {
    'sourceType': sourceType,
    'productId': productId,
    'name': name,
    'image': image,
    'price': price,
    'description': description,
    'categoryName': categoryName,
  };

  AppProductSnapshot copyWith({
    String? sourceType,
    String? productId,
    String? name,
    String? image,
    double? price,
    String? description,
    String? categoryName,
  }) => AppProductSnapshot(
    sourceType: sourceType ?? this.sourceType,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    image: image ?? this.image,
    price: price ?? this.price,
    description: description ?? this.description,
    categoryName: categoryName ?? this.categoryName,
  );

  static String? _nullable(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  @override
  bool operator ==(Object other) =>
      other is AppProductSnapshot && other.compositeKey == compositeKey;

  @override
  int get hashCode => compositeKey.hashCode;
}
