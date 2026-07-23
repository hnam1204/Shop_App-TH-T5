import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/payment.dart';
import '../../models/payment_detail.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_state_widgets.dart';
import '../../core/config/app_flavor.dart';

class PaymentDetailPage extends StatefulWidget {
  final int paymentId;

  const PaymentDetailPage({super.key, required this.paymentId});

  @override
  State<PaymentDetailPage> createState() => _PaymentDetailPageState();
}

class _PaymentDetailPageState extends State<PaymentDetailPage> {
  final PaymentService _service = PaymentService();
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  final DateFormat _date = DateFormat('dd/MM/yyyy HH:mm');
  Payment? _payment;
  List<PaymentDetail> _details = const [];
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
      final payment = await _service.getPayment(widget.paymentId);
      final details = await _service.getPaymentDetails(widget.paymentId);
      if (!mounted) return;
      setState(() {
        _payment = payment;
        _details = details;
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
      appBar: AppBar(
        title: Text(
          AppFlavorConfig.isStore ? 'Chi tiết đơn hàng' : 'Chi tiết hóa đơn',
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingState(message: 'Đang tải chi tiết hóa đơn...');
    }
    if (_error != null || _payment == null) {
      return ErrorState(
        message: 'Không thể tải chi tiết hóa đơn.',
        onRetry: _load,
      );
    }
    final payment = _payment;
    if (payment == null) {
      return ErrorState(message: 'Không tìm thấy hóa đơn.', onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Ngày tạo',
                    value: _date.format(payment.createdAt.toLocal()),
                  ),
                  _InfoRow(
                    label: 'Khách hàng',
                    value: payment.customerName ?? 'Khách',
                  ),
                  _InfoRow(label: 'Phương thức', value: payment.paymentMethod),
                  _InfoRow(label: 'Trạng thái', value: payment.status),
                  if (payment.note?.isNotEmpty ?? false)
                    _InfoRow(label: 'Ghi chú', value: payment.note ?? ''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Sản phẩm',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          for (final detail in _details)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    AppNetworkImage(
                      imageUrl: detail.productImage,
                      width: 68,
                      height: 68,
                      borderRadius: BorderRadius.circular(12),
                      fallbackIcon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_currency.format(detail.unitPrice)} × '
                            '${detail.quantity}',
                          ),
                          Text(
                            detail.productSource,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _currency.format(detail.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Text(
                    'Tổng tiền',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const Spacer(),
                  Text(
                    _currency.format(payment.totalAmount),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
