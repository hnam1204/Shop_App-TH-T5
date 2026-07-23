import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import 'order_success_page.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cartProvider).value;
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    if (state == null || state.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: const Center(child: Text('Giỏ hàng của bạn đang trống')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Phương thức thanh toán',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.local_shipping_outlined),
                title: Text('Thanh toán khi nhận hàng'),
                subtitle: Text('Bạn thanh toán khi đơn hàng được giao đến.'),
                trailing: Icon(Icons.check_circle),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sản phẩm (${state.totalQuantity})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final item in state.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text(
                  '${item.quantity} × ${currency.format(item.product.price)}',
                ),
                trailing: Text(
                  currency.format(item.subtotal),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Ghi chú cho đơn hàng',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Tổng cộng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      currency.format(state.totalAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Xác nhận đặt hàng'),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final result = await PaymentService().checkout(
        note: _noteController.text,
      );
      await ref.read(cartProvider.notifier).reload();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessPage(
            paymentId: result.payment.id,
            totalAmount: result.payment.totalAmount,
            warning: result.warning,
          ),
        ),
      );
    } on CheckoutException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      setState(() => _submitting = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể hoàn tất đơn hàng.')),
      );
      setState(() => _submitting = false);
    }
  }
}
