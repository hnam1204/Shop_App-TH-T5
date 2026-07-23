import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/database/database_constants.dart';
import '../core/config/app_flavor.dart';
import '../data/firestore/week8_payment_firestore_repository.dart';
import '../models/payment.dart';
import '../models/payment_detail.dart';
import 'hive_cart_service.dart';
import 'local_storage_service.dart';

class CheckoutException implements Exception {
  final String message;
  const CheckoutException(this.message);
  @override
  String toString() => message;
}

class EmptyCartException extends CheckoutException {
  const EmptyCartException() : super('Giỏ hàng đang trống.');
}

class PaymentHistoryAuthenticationException extends CheckoutException {
  const PaymentHistoryAuthenticationException()
    : super('Vui lòng đăng nhập để xem lịch sử hóa đơn.');
}

class CheckoutResult {
  final Payment payment;
  final bool cartCleared;
  final String? warning;
  const CheckoutResult({
    required this.payment,
    required this.cartCleared,
    this.warning,
  });
}

class PaymentService {
  final Week8PaymentFirestoreRepository _repository;
  final HiveCartService _cartService;
  final FirebaseAuth _auth;

  PaymentService({
    Week8PaymentFirestoreRepository? repository,
    HiveCartService? cartService,
    FirebaseAuth? auth,
  }) : _repository = repository ?? Week8PaymentFirestoreRepository(),
       _cartService = cartService ?? HiveCartService(),
       _auth = auth ?? FirebaseAuth.instance;

  Future<CheckoutResult> checkout({
    String paymentMethod = DatabaseConstants.paymentMethodCash,
    String? note,
  }) async {
    final user = _requireUser();
    final items = _cartService.getCartItems();
    if (items.isEmpty) throw const EmptyCartException();
    var total = 0.0;
    final details = <PaymentDetail>[];
    for (final item in items) {
      if (item.quantity <= 0 || !item.price.isFinite || item.price < 0) {
        throw const CheckoutException(
          'Thông tin sản phẩm trong giỏ không hợp lệ.',
        );
      }
      final subtotal = item.price * item.quantity;
      total += subtotal;
      details.add(
        PaymentDetail(
          paymentId: 0,
          productSource: item.sourceType,
          productId: item.productId,
          productName: item.productName,
          productImage: item.imageUrl.isEmpty ? null : item.imageUrl,
          quantity: item.quantity,
          unitPrice: item.price,
          subtotal: subtotal,
        ),
      );
    }
    final localUser = await LocalStorageService.getCurrentUser();
    final cartFingerprint = items
        .map(
          (item) =>
              '${item.logicalKey}:${item.quantity}:${item.price}:${item.addedAt.microsecondsSinceEpoch}',
        )
        .join('|');
    final token = '${user.uid}-${_stableHash(cartFingerprint)}';
    final payment = Payment(
      totalAmount: total,
      paymentMethod: paymentMethod,
      status: DatabaseConstants.paymentStatusCompleted,
      customerId: user.uid,
      customerName: localUser?.fullName.trim().isNotEmpty == true
          ? localUser!.fullName.trim()
          : user.displayName,
      note: _optional(note),
      createdAt: DateTime.now().toUtc(),
      itemCount: details.length,
      checkoutToken: token,
    );
    final committed = await _repository.checkout(payment, details);
    try {
      await _cartService.clearCart();
      return CheckoutResult(payment: committed, cartCleared: true);
    } catch (_) {
      return CheckoutResult(
        payment: committed,
        cartCleared: false,
        warning: 'Thanh toán thành công nhưng chưa thể làm trống giỏ hàng.',
      );
    }
  }

  Future<List<Payment>> getPayments() async {
    final user = _auth.currentUser;
    if (AppFlavorConfig.isDemo) {
      debugPrint(
        'Payment history FirebaseAuth.currentUser: ${user?.uid ?? 'null'}',
      );
    }
    if (user == null) {
      throw const PaymentHistoryAuthenticationException();
    }
    return _repository.getPayments(customerId: user.uid);
  }

  Future<Payment> getPayment(int id) async {
    final user = _requireUser();
    final payment = await _repository.getPaymentById(id);
    if (payment == null || payment.customerId != user.uid) {
      throw const CheckoutException('Không tìm thấy hóa đơn.');
    }
    return payment;
  }

  Future<List<PaymentDetail>> getPaymentDetails(int paymentId) async {
    await getPayment(paymentId);
    return _repository.getPaymentDetails(paymentId);
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const CheckoutException(
        'Vui lòng đăng nhập để sử dụng chức năng này.',
      );
    }
    return user;
  }

  String? _optional(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? null : clean;
  }

  String _stableHash(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0xffffffff;
    }
    return hash.toRadixString(16);
  }
}
