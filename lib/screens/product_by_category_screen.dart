import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_product_snapshot.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/product_item.dart';
import 'product_detail_screen.dart';

class ProductByCategoryScreen extends ConsumerStatefulWidget {
  final String categoryName;
  final String slug;

  const ProductByCategoryScreen({
    super.key,
    required this.categoryName,
    required this.slug,
  });

  @override
  ConsumerState<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState
    extends ConsumerState<ProductByCategoryScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProductsByCategory(widget.slug);
  }

  void _retry() {
    setState(() {
      _productsFuture = _productService.fetchProductsByCategory(widget.slug);
    });
  }

  void _openDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  Future<void> _addToCart(Product product) async {
    await ref
        .read(cartProvider.notifier)
        .addProduct(AppProductSnapshot.fromApi(product));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${product.title}" vào giỏ hàng'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Đang tải sản phẩm...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const EmptyState(message: 'Danh mục này chưa có sản phẩm');
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final appProduct = AppProductSnapshot.fromApi(product);
              final isFavourite = ref.watch(
                isFavouriteProvider(appProduct.compositeKey),
              );
              return ProductItem(
                product: product,
                onTap: () => _openDetail(product),
                onAddToCart: () => _addToCart(product),
                isFavourite: isFavourite,
                onToggleFavourite: () =>
                    ref.read(favouriteProvider.notifier).toggle(appProduct),
              );
            },
          );
        },
      ),
    );
  }
}
