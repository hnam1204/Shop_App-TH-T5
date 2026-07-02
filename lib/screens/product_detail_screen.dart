import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';

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
      appBar: AppBar(title: const Text('Product Detail')),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Dang tai chi tiet...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final product = snapshot.data;
          if (product == null) {
            return const EmptyState(message: 'Khong tim thay san pham');
          }

          return _ProductDetailContent(product: product);
        },
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final Product product;

  const _ProductDetailContent({required this.product});

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _ProductImage(source: product.thumbnail),
                ),
              ),
            ),
            if (images.length > 1) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: _ProductImage(source: images[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipLabel(label: product.category),
                if (product.brand.isNotEmpty) _ChipLabel(label: product.brand),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              product.title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatter.format(product.price),
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.percent_rounded,
                    title: 'Discount',
                    value: '${product.discountPercentage.toStringAsFixed(1)}%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.star_rounded,
                    title: 'Rating',
                    value: product.rating.toStringAsFixed(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Stock',
                    value: product.stock.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Add to Cart'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm vào giỏ hàng'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String source;

  const _ProductImage({required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _ImageFallback(colorScheme: colorScheme);
        },
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _ImageFallback(colorScheme: colorScheme);
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImageFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.primary.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.primary,
        size: 42,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
          fontWeight: FontWeight.w800,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 6),
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
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
