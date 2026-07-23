class HiveCartModel {
  final String id;
  final String sourceType;
  final String productId;
  final String productName;
  final String imageUrl;
  final double price;
  final int quantity;
  final DateTime addedAt;

  HiveCartModel({
    required this.id,
    this.sourceType = 'hive',
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => price * quantity;
  String get logicalKey => '$sourceType:$productId';

  factory HiveCartModel.fromMap(Map<dynamic, dynamic> map) {
    return HiveCartModel(
      id: map['id']?.toString() ?? '',
      sourceType: map['sourceType']?.toString() ?? 'hive',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      price: _toDouble(map['price']),
      quantity: _toInt(map['quantity']),
      addedAt: map['addedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['addedAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceType': sourceType,
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  HiveCartModel copyWith({
    String? id,
    String? sourceType,
    String? productId,
    String? productName,
    String? imageUrl,
    double? price,
    int? quantity,
    DateTime? addedAt,
  }) {
    return HiveCartModel(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
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
