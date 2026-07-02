import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/product_item.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  final List<Product> products = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  int skip = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        isLoading ||
        isLoadingMore ||
        !hasMore) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (isLoading || isLoadingMore) return;

    setState(() {
      errorMessage = null;
      if (reset) {
        isLoading = true;
        products.clear();
        skip = 0;
        hasMore = true;
      } else {
        isLoadingMore = true;
      }
    });

    try {
      final newProducts = await _productService.fetchProducts(
        limit: limit,
        skip: skip,
      );
      if (!mounted) return;

      setState(() {
        products.addAll(newProducts);
        skip += newProducts.length;
        hasMore = newProducts.length == limit;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refresh() {
    return _loadProducts(reset: true);
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
    if (isLoading && products.isEmpty) {
      return const LoadingState(message: 'Dang tai san pham...');
    }

    if (errorMessage != null && products.isEmpty) {
      return ErrorState(
        message: errorMessage!,
        onRetry: () => _loadProducts(reset: true),
      );
    }

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            EmptyState(message: 'Chua co san pham'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == products.length) {
            if (isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: _loadProducts,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Load lai'),
                ),
              );
            }
            if (!hasMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'Da tai het san pham',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox(height: 12);
          }

          final product = products[index];
          return ProductItem(
            product: product,
            onTap: () => _openDetail(product),
          );
        },
      ),
    );
  }
}
