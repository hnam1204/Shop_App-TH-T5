import 'package:flutter/material.dart';

import '../services/hive_cart_service.dart';

class HiveCartBadgeIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final HiveCartService? service;

  const HiveCartBadgeIcon({super.key, required this.onPressed, this.service});

  @override
  Widget build(BuildContext context) {
    final cartService = service ?? HiveCartService();
    return ValueListenableBuilder(
      valueListenable: cartService.listenable,
      builder: (context, _, _) {
        final count = cartService.getTotalQuantity();
        return IconButton(
          tooltip: 'Giỏ hàng SQLite/Hive',
          onPressed: onPressed,
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
