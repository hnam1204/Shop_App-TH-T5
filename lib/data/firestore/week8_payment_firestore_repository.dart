import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../constants/week8_firestore_constants.dart';
import '../../core/config/app_flavor.dart';
import '../../models/payment.dart';
import '../../models/payment_detail.dart';
import 'week8_counter.dart';

class Week8PaymentFirestoreRepository {
  final FirebaseFirestore _firestore;

  Week8PaymentFirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection(Week8FirestoreConstants.payments);

  Future<Payment> checkout(Payment payment, List<PaymentDetail> details) async {
    final token = payment.checkoutToken;
    if (token == null || token.isEmpty) {
      throw ArgumentError('Checkout token is required.');
    }
    final existing = await _payments
        .where('checkoutToken', isEqualTo: token)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return Payment.fromFirestore(existing.docs.first);
    }
    return _firestore.runTransaction((transaction) async {
      final id = await nextWeek8Id(
        transaction,
        _firestore,
        Week8FirestoreConstants.paymentCounter,
      );
      final committed = payment.copyWith(id: id, itemCount: details.length);
      transaction.set(_payments.doc('$id'), committed.toFirestore());
      final detailCollection = _firestore.collection(
        Week8FirestoreConstants.paymentDetails,
      );
      for (final detail in details) {
        transaction.set(
          detailCollection.doc(),
          detail.copyWith(paymentId: id).toFirestore(),
        );
      }
      return committed;
    });
  }

  Future<List<Payment>> getPayments({String? customerId}) async {
    try {
      Query<Map<String, dynamic>> query = _payments;
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }
      final snapshot = await query.orderBy('createdAt', descending: true).get();
      if (snapshot.docs.isEmpty) return List<Payment>.empty();
      return snapshot.docs.map(Payment.fromFirestore).toList(growable: false);
    } on FirebaseException catch (error, stackTrace) {
      if (AppFlavorConfig.isDemo) {
        debugPrint(
          'Week8 payment history FirebaseException.code: ${error.code}',
        );
        debugPrint(
          'Week8 payment history FirebaseException.message: ${error.message}',
        );
        debugPrintStack(
          label: 'Week8 payment history stackTrace',
          stackTrace: stackTrace,
        );
      }
      rethrow;
    }
  }

  Future<Payment?> getPaymentById(int id) async {
    final snapshot = await _payments.doc('$id').get();
    return snapshot.exists ? Payment.fromFirestore(snapshot) : null;
  }

  Future<List<PaymentDetail>> getPaymentDetails(int paymentId) async {
    final result = await _firestore
        .collection(Week8FirestoreConstants.paymentDetails)
        .where('paymentId', isEqualTo: paymentId)
        .get();
    return result.docs.map(PaymentDetail.fromFirestore).toList();
  }

  Future<bool> checkoutTokenExists(String token) async {
    final result = await _payments
        .where('checkoutToken', isEqualTo: token)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }
}
