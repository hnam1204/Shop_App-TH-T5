import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/cart_provider.dart';
import '../services/payment_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_state_widgets.dart';
import 'sqlite/payment_history_page.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          IconButton(
            tooltip: 'Xóa tất cả',
            onPressed: ref.watch(cartIsEmptyProvider)
                ? null
                : () => _confirmClear(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: cart.when(
          loading: () => const LoadingState(message: 'Đang tải giỏ hàng...'),
          error: (_, _) => ErrorState(
            message: 'Không thể đọc dữ liệu giỏ hàng.',
            onRetry: () => ref.read(cartProvider.notifier).reload(),
          ),
          data: (state) => state.isEmpty
              ? const EmptyState(
                  message: 'Giỏ hàng đang trống.',
                  icon: Icons.shopping_cart_outlined,
                )
              : _CartContent(state: state),
        ),
      ),
      bottomNavigationBar: cart.whenOrNull(
        data: (state) => state.isEmpty ? null : _CartSummary(state: state),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tất cả sản phẩm?'),
        content: const Text('Giỏ hàng sẽ được làm trống.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(cartProvider.notifier).clearCart();
      if (context.mounted) _message(context, 'Đã xóa giỏ hàng.');
    } catch (_) {
      if (context.mounted) {
        _message(context, 'Không thể xóa giỏ hàng.', error: true);
      }
    }
  }
}

class _CartContent extends ConsumerWidget {
  final CartState state;
  const _CartContent({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AppNetworkImage(
                  imageUrl: item.product.image,
                  width: 72,
                  height: 72,
                  borderRadius: BorderRadius.circular(12),
                  fallbackIcon: Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(currency.format(item.product.price)),
                      Text(
                        'Thành tiền: ${currency.format(item.subtotal)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Giảm',
                            onPressed: state.isSaving
                                ? null
                                : () => ref
                                      .read(cartProvider.notifier)
                                      .decreaseQuantity(item.key),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            tooltip: 'Tăng',
                            onPressed: state.isSaving
                                ? null
                                : () => ref
                                      .read(cartProvider.notifier)
                                      .increaseQuantity(item.key),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  onPressed: state.isSaving
                      ? null
                      : () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item.key),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartSummary extends ConsumerWidget {
  final CartState state;
  const _CartSummary({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return SafeArea(
      child: Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.totalQuantity} sản phẩm\n'
                  '${currency.format(state.totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton.icon(
                onPressed: state.isSaving
                    ? null
                    : () => _checkout(context, ref),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Thanh toán'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    try {
      final result = await PaymentService().checkout();
      await ref.read(cartProvider.notifier).reload();
      if (!context.mounted) return;
      _message(
        context,
        result.warning ?? 'Thanh toán thành công.',
        error: result.warning != null,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
      );
    } on CheckoutException catch (error) {
      if (context.mounted) _message(context, error.message, error: true);
    } catch (_) {
      if (context.mounted) {
        _message(context, 'Thanh toán không thành công.', error: true);
      }
    }
  }
}

void _message(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
