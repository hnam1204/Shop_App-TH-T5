import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFbModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String categoryId;
  final String categoryName;
  final String imageUrl;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductFbModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrl,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductFbModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ProductFbModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      price: _toDouble(data['price']),
      description: data['description']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      categoryName: data['categoryName']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      isAvailable: data['isAvailable'] is bool
          ? data['isAvailable'] as bool
          : true,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
