import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/app_product_snapshot.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/app_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final int? productId;
  final Product? product;

  const ProductDetailScreen({super.key, this.productId, this.product})
    : assert(productId != null || product != null);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _loadProduct();
  }

  Future<Product> _loadProduct() {
    final product = widget.product;
    if (product != null) {
      return Future.value(product);
    }
    return _productService.fetchProductDetail(widget.productId!);
  }

  void _retry() {
    setState(() {
      _productFuture = _loadProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Đang tải chi tiết...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final product = snapshot.data;
          if (product == null) {
            return const EmptyState(message: 'Không tìm thấy sản phẩm');
          }

          return _ProductDetailContent(product: product);
        },
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  final Product product;

  const _ProductDetailContent({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );
    final images = product.images.isNotEmpty
        ? product.images
        : product.thumbnail.isNotEmpty
        ? [product.thumbnail]
        : <String>[];
    final appProduct = AppProductSnapshot.fromApi(product);
    final isFavourite = ref.watch(isFavouriteProvider(appProduct.compositeKey));

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppNetworkImage(
                          imageUrl: product.thumbnail,
                          fit: BoxFit.contain,
                          fallbackIcon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (images.length > 1) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 76,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 76,
                              height: 76,
                              child: AppNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.contain,
                                fallbackIcon: Icons.shopping_bag_outlined,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChipLabel(label: product.category),
                      if (product.brand.isNotEmpty)
                        _ChipLabel(label: product.brand),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatter.format(product.price),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.percent_rounded,
                          title: 'Giảm giá',
                          value:
                              '${product.discountPercentage.toStringAsFixed(1)}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.star_rounded,
                          title: 'Đánh giá',
                          value: product.rating.toStringAsFixed(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          icon: Icons.inventory_2_outlined,
                          title: 'Tồn kho',
                          value: product.stock.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: isFavourite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
                  onPressed: () =>
                      ref.read(favouriteProvider.notifier).toggle(appProduct),
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                      label: const Text('Thêm vào giỏ hàng'),
                      onPressed: () async {
                        await ref
                            .read(cartProvider.notifier)
                            .addProduct(appProduct);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm vào giỏ hàng'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;

  const _ChipLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
