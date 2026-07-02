import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/product_item.dart';
import 'product_detail_screen.dart';

class ProductByCategoryScreen extends StatefulWidget {
  final String categoryName;
  final String slug;

  const ProductByCategoryScreen({
    super.key,
    required this.categoryName,
    required this.slug,
  });

  @override
  State<ProductByCategoryScreen> createState() =>
      _ProductByCategoryScreenState();
}

class _ProductByCategoryScreenState extends State<ProductByCategoryScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Dang tai san pham...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const EmptyState(message: 'Danh muc nay chua co san pham');
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductItem(
                product: product,
                onTap: () => _openDetail(product),
              );
            },
          );
        },
      ),
    );
  }
}
