import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favourite_provider.dart';

class FavouriteBadgeIcon extends ConsumerWidget {
  final VoidCallback onPressed;

  const FavouriteBadgeIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favouriteCountProvider);
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Yêu thích, $count sản phẩm',
      button: true,
      child: IconButton(
        tooltip: 'Yêu thích',
        onPressed: onPressed,
        icon: Badge(
          isLabelVisible: count > 0,
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(count > 99 ? '99+' : '$count', key: ValueKey(count)),
          ),
          backgroundColor: colors.error,
          textColor: colors.onError,
          child: const Icon(Icons.favorite_border),
        ),
      ),
    );
  }
}
