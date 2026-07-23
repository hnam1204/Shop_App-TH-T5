import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryFbModel {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryFbModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryFbModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CategoryFbModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
