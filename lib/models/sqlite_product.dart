import '../core/database/database_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SqliteProduct {
  final int? id;
  final String name;
  final double price;
  final String? image;
  final String description;
  final int categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SqliteProduct({
    this.id,
    required this.name,
    required this.price,
    this.image,
    this.description = '',
    required this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory SqliteProduct.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return SqliteProduct(
      id: (data['id'] as num?)?.toInt() ?? int.tryParse(document.id),
      name: data['name']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      image: data['image']?.toString(),
      description: data['description']?.toString() ?? '',
      categoryId: (data['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: data['categoryName']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory SqliteProduct.fromMap(Map<String, Object?> map) {
    final priceValue = map[DatabaseConstants.price];
    return SqliteProduct(
      id: map[DatabaseConstants.id] as int?,
      name: map[DatabaseConstants.name]?.toString() ?? '',
      price: priceValue is num ? priceValue.toDouble() : 0,
      image: map[DatabaseConstants.image]?.toString(),
      description: map[DatabaseConstants.description]?.toString() ?? '',
      categoryId: map[DatabaseConstants.categoryId] as int? ?? 0,
      categoryName: map[DatabaseConstants.categoryName]?.toString(),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {DatabaseConstants.id: id, ...toInsertMap()};

  Map<String, Object?> toInsertMap() => {
    DatabaseConstants.name: name,
    DatabaseConstants.price: price,
    DatabaseConstants.image: image,
    DatabaseConstants.description: description,
    DatabaseConstants.categoryId: categoryId,
  };

  Map<String, dynamic> toFirestore({bool isCreate = false}) => {
    'id': id,
    'name': name.trim(),
    'normalizedName': name.trim().toLowerCase(),
    'price': price,
    'image': image,
    'description': description,
    'categoryId': categoryId,
    'categoryName': categoryName ?? '',
    if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  SqliteProduct copyWith({
    int? id,
    String? name,
    double? price,
    String? image,
    String? description,
    int? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SqliteProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
