import '../core/database/database_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final int? id;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String? customerId;
  final String? customerName;
  final String? note;
  final DateTime createdAt;
  final int? itemCount;
  final String? checkoutToken;

  const Payment({
    this.id,
    required this.totalAmount,
    this.paymentMethod = DatabaseConstants.paymentMethodCash,
    this.status = DatabaseConstants.paymentStatusCompleted,
    this.customerId,
    this.customerName,
    this.note,
    required this.createdAt,
    this.itemCount,
    this.checkoutToken,
  });

  factory Payment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return Payment(
      id: _toInt(data['id']) ?? int.tryParse(document.id),
      totalAmount: _toDouble(data['totalAmount']),
      paymentMethod: _toStringOrDefault(
        data['paymentMethod'],
        DatabaseConstants.paymentMethodCash,
      ),
      status: _toStringOrDefault(
        data['status'],
        DatabaseConstants.paymentStatusCompleted,
      ),
      customerId: _toNullableString(data['customerId']),
      customerName: _toNullableString(data['customerName']),
      note: _toNullableString(data['note']),
      createdAt: _toDateTime(data['createdAt']),
      itemCount: _toInt(data['itemCount']) ?? 0,
      checkoutToken: _toNullableString(data['checkoutToken']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'status': status,
    'customerId': customerId,
    'customerName': customerName,
    'note': note,
    'itemCount': itemCount,
    'checkoutToken': checkoutToken,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Payment.fromMap(Map<String, Object?> map) {
    final amount = map[DatabaseConstants.totalAmount];
    final dateValue = map[DatabaseConstants.createdAt]?.toString();
    return Payment(
      id: map[DatabaseConstants.id] as int?,
      totalAmount: amount is num ? amount.toDouble() : 0,
      paymentMethod:
          map[DatabaseConstants.paymentMethod]?.toString() ??
          DatabaseConstants.paymentMethodCash,
      status:
          map[DatabaseConstants.status]?.toString() ??
          DatabaseConstants.paymentStatusCompleted,
      customerId: map[DatabaseConstants.customerId]?.toString(),
      customerName: map[DatabaseConstants.customerName]?.toString(),
      note: map[DatabaseConstants.note]?.toString(),
      createdAt:
          DateTime.tryParse(dateValue ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      itemCount: map[DatabaseConstants.itemCount] as int?,
    );
  }

  Map<String, Object?> toMap() => {DatabaseConstants.id: id, ...toInsertMap()};

  Map<String, Object?> toInsertMap() => {
    DatabaseConstants.totalAmount: totalAmount,
    DatabaseConstants.paymentMethod: paymentMethod,
    DatabaseConstants.status: status,
    DatabaseConstants.customerId: customerId,
    DatabaseConstants.customerName: customerName,
    DatabaseConstants.note: note,
    DatabaseConstants.createdAt: createdAt.toUtc().toIso8601String(),
  };

  Payment copyWith({
    int? id,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    String? customerId,
    String? customerName,
    String? note,
    DateTime? createdAt,
    int? itemCount,
    String? checkoutToken,
  }) {
    return Payment(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      itemCount: itemCount ?? this.itemCount,
      checkoutToken: checkoutToken ?? this.checkoutToken,
    );
  }

  static int? _toInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  static String _toStringOrDefault(Object? value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _toNullableString(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
