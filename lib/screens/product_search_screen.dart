import 'dart:async';

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

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _keyword = '';
  String _searchText = '';
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onKeywordChanged(String value) {
    setState(() {
      _searchText = value;
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchProducts(value.trim());
    });
  }

  Future<void> _searchProducts(String keyword) async {
    final currentRequest = ++_requestId;
    setState(() {
      _keyword = keyword;
      _errorMessage = null;
      if (keyword.isEmpty) {
        _products = [];
        _isLoading = false;
      } else {
        _isLoading = true;
      }
    });

    if (keyword.isEmpty) return;

    try {
      final products = await _productService.searchProducts(keyword);
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _products = products;
      });
    } catch (error) {
      if (!mounted || currentRequest != _requestId) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted && currentRequest == _requestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _requestId++;
    setState(() {
      _searchText = '';
      _keyword = '';
      _products = [];
      _errorMessage = null;
      _isLoading = false;
    });
  }

  void _retry() {
    _searchProducts(_keyword);
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
      appBar: AppBar(title: const Text('Tìm kiếm sản phẩm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onKeywordChanged,
              onSubmitted: (value) => _searchProducts(value.trim()),
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                hintText: 'Điện thoại, laptop, đồng hồ...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_keyword.isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        message: 'Nhập tên sản phẩm để tìm kiếm',
      );
    }

    if (_isLoading) {
      return const LoadingState(message: 'Đang tìm kiếm...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _retry);
    }

    if (_products.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        message: 'Không tìm thấy sản phẩm phù hợp',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
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
  }
}
