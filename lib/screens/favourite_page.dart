import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/app_product_snapshot.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_state_widgets.dart';
import 'product_screen.dart';

class FavouritePage extends ConsumerWidget {
  final bool embeddedInNavigation;

  const FavouritePage({super.key, this.embeddedInNavigation = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embeddedInNavigation,
        title: const Text('Yêu thích'),
        actions: [
          IconButton(
            tooltip: 'Xóa tất cả',
            onPressed: ref.watch(favouriteCountProvider) == 0
                ? null
                : () => _confirmClear(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: favourites.when(
          loading: () => const LoadingState(message: 'Đang tải yêu thích...'),
          error: (_, _) => ErrorState(
            message: 'Không thể đọc danh sách yêu thích.',
            onRetry: () => ref.read(favouriteProvider.notifier).reload(),
          ),
          data: (state) => state.items.isEmpty
              ? EmptyState(
                  message: 'Chưa có sản phẩm yêu thích',
                  icon: Icons.favorite_border,
                  actionLabel: 'Khám phá sản phẩm',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductScreen()),
                  ),
                )
              : _FavouriteGrid(items: state.items),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tất cả yêu thích?'),
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
    if (confirmed == true) {
      await ref.read(favouriteProvider.notifier).clear();
    }
  }
}

class _FavouriteGrid extends ConsumerWidget {
  final List<AppProductSnapshot> items;
  const _FavouriteGrid({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AppNetworkImage(
                      imageUrl: product.image,
                      fallbackIcon: Icons.inventory_2_outlined,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          product.categoryName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currency.format(product.price),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: 'Thêm vào giỏ',
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .addProduct(product),
                              icon: const Icon(
                                Icons.add_shopping_cart_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Bỏ yêu thích',
                              onPressed: () => ref
                                  .read(favouriteProvider.notifier)
                                  .toggle(product),
                              icon: const Icon(Icons.favorite),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
