import 'package:sqflite/sqflite.dart';

import '../../core/database/database_constants.dart';
import '../../core/database/database_helper.dart';
import '../../models/payment.dart';
import '../../models/payment_detail.dart';

class PaymentSqliteDataSource {
  final DatabaseHelper _databaseHelper;

  PaymentSqliteDataSource({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<Payment> insertCheckout(Payment payment, List<PaymentDetail> details) {
    return _databaseHelper.transaction((transaction) async {
      final paymentId = await transaction.insert(
        DatabaseConstants.paymentTable,
        payment.toInsertMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      if (paymentId <= 0) {
        throw StateError('Không thể tạo hóa đơn.');
      }
      for (final detail in details) {
        final detailId = await transaction.insert(
          DatabaseConstants.paymentDetailTable,
          detail.copyWith(paymentId: paymentId).toInsertMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        if (detailId <= 0) {
          throw StateError('Không thể lưu chi tiết hóa đơn.');
        }
      }
      return payment.copyWith(id: paymentId, itemCount: details.length);
    });
  }

  Future<List<Payment>> getPayments() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        p.*,
        COUNT(d.${DatabaseConstants.id}) AS ${DatabaseConstants.itemCount}
      FROM ${DatabaseConstants.paymentTable} p
      LEFT JOIN ${DatabaseConstants.paymentDetailTable} d
        ON d.${DatabaseConstants.paymentId} = p.${DatabaseConstants.id}
      GROUP BY p.${DatabaseConstants.id}
      ORDER BY p.${DatabaseConstants.createdAt} DESC,
        p.${DatabaseConstants.id} DESC
    ''');
    return rows.map(Payment.fromMap).toList(growable: false);
  }

  Future<Payment?> getPaymentById(int id) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT
          p.*,
          COUNT(d.${DatabaseConstants.id}) AS ${DatabaseConstants.itemCount}
        FROM ${DatabaseConstants.paymentTable} p
        LEFT JOIN ${DatabaseConstants.paymentDetailTable} d
          ON d.${DatabaseConstants.paymentId} = p.${DatabaseConstants.id}
        WHERE p.${DatabaseConstants.id} = ?
        GROUP BY p.${DatabaseConstants.id}
        LIMIT 1
      ''',
      [id],
    );
    return rows.isEmpty ? null : Payment.fromMap(rows.first);
  }

  Future<List<PaymentDetail>> getPaymentDetails(int paymentId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      DatabaseConstants.paymentDetailTable,
      where: '${DatabaseConstants.paymentId} = ?',
      whereArgs: [paymentId],
      orderBy: '${DatabaseConstants.id} ASC',
    );
    return rows.map(PaymentDetail.fromMap).toList(growable: false);
  }
}
