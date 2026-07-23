class HiveProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final int stock;
  final DateTime createdAt;
  final DateTime updatedAt;

  HiveProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HiveProductModel.fromMap(Map<dynamic, dynamic> map) {
    return HiveProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      price: _toDouble(map['price']),
      imageUrl: map['imageUrl']?.toString() ?? '',
      stock: _toInt(map['stock']),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  HiveProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HiveProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
