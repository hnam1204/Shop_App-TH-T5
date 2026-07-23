import '../core/database/database_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentDetail {
  final String? documentId;
  final int paymentId;
  final String productSource;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const PaymentDetail({
    this.documentId,
    required this.paymentId,
    required this.productSource,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory PaymentDetail.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return PaymentDetail(
      documentId: document.id,
      paymentId: (data['paymentId'] as num?)?.toInt() ?? 0,
      productSource: data['productSource']?.toString() ?? '',
      productId: data['productId']?.toString() ?? '',
      productName: data['productName']?.toString() ?? '',
      productImage: data['productImage']?.toString(),
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'paymentId': paymentId,
    'productSource': productSource,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subtotal': subtotal,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory PaymentDetail.fromMap(Map<String, Object?> map) {
    final unitPrice = map[DatabaseConstants.unitPrice];
    final subtotal = map[DatabaseConstants.subtotal];
    return PaymentDetail(
      documentId: map[DatabaseConstants.id]?.toString(),
      paymentId: map[DatabaseConstants.paymentId] as int? ?? 0,
      productSource: map[DatabaseConstants.productSource]?.toString() ?? '',
      productId: map[DatabaseConstants.productId]?.toString() ?? '',
      productName: map[DatabaseConstants.productName]?.toString() ?? '',
      productImage: map[DatabaseConstants.productImage]?.toString(),
      quantity: map[DatabaseConstants.quantity] as int? ?? 0,
      unitPrice: unitPrice is num ? unitPrice.toDouble() : 0,
      subtotal: subtotal is num ? subtotal.toDouble() : 0,
    );
  }

  Map<String, Object?> toMap() => {
    DatabaseConstants.id: documentId,
    ...toInsertMap(),
  };

  Map<String, Object?> toInsertMap() => {
    DatabaseConstants.paymentId: paymentId,
    DatabaseConstants.productSource: productSource,
    DatabaseConstants.productId: productId,
    DatabaseConstants.productName: productName,
    DatabaseConstants.productImage: productImage,
    DatabaseConstants.quantity: quantity,
    DatabaseConstants.unitPrice: unitPrice,
    DatabaseConstants.subtotal: subtotal,
  };

  PaymentDetail copyWith({
    String? documentId,
    int? paymentId,
    String? productSource,
    String? productId,
    String? productName,
    String? productImage,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) {
    return PaymentDetail(
      documentId: documentId ?? this.documentId,
      paymentId: paymentId ?? this.paymentId,
      productSource: productSource ?? this.productSource,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
