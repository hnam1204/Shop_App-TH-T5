import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_state_widgets.dart';
import 'payment_detail_page.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final PaymentService _service = PaymentService();
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  final DateFormat _date = DateFormat('dd/MM/yyyy HH:mm');
  List<Payment> _payments = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payments = await _service.getPayments();
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử hóa đơn')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingState(message: 'Đang tải lịch sử hóa đơn...');
    }
    final error = _error;
    if (error != null) {
      return ErrorState(
        message: error is PaymentHistoryAuthenticationException
            ? error.message
            : 'Không thể tải lịch sử hóa đơn.',
        onRetry: _load,
      );
    }
    if (_payments.isEmpty) {
      return const EmptyState(
        message: 'Chưa có hóa đơn nào.',
        icon: Icons.receipt_long_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final payment = _payments[index];
          final paymentId = payment.id;
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: paymentId == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentDetailPage(paymentId: paymentId),
                      ),
                    ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(child: Text('#${payment.id ?? '-'}')),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hóa đơn #${payment.id ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(_date.format(payment.createdAt.toLocal())),
                          const SizedBox(height: 4),
                          Text(
                            '${payment.itemCount ?? 0} dòng · '
                            '${payment.paymentMethod} · ${payment.status}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (payment.customerName?.isNotEmpty ?? false)
                            Text(
                              payment.customerName ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currency.format(payment.totalAmount),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
