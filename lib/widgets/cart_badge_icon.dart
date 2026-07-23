import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';

class CartBadgeIcon extends ConsumerWidget {
  final VoidCallback onPressed;

  const CartBadgeIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartTotalQuantityProvider);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Giỏ hàng, $count sản phẩm',
      button: true,
      child: IconButton(
        tooltip: 'Giỏ hàng',
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: count > 0,
          label: Text(count > 99 ? '99+' : '$count'),
          backgroundColor: colors.error,
          textColor: colors.onError,
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
