import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'sqlite/payment_history_page.dart';

class OrderSuccessPage extends StatelessWidget {
  final int? paymentId;
  final double totalAmount;
  final String? warning;

  const OrderSuccessPage({
    super.key,
    required this.paymentId,
    required this.totalAmount,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1),
                    duration: const Duration(milliseconds: 220),
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 96,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Đặt hàng thành công',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Mã đơn hàng: #${paymentId ?? '-'}'),
                  Text(
                    currency.format(totalAmount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (warning != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      warning!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PaymentHistoryPage(),
                        ),
                      ),
                      child: const Text('Xem đơn hàng'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
