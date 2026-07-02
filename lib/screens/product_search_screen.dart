import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/product_item.dart';
import 'product_detail_screen.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _keyword = '';
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onKeywordChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(value.trim());
    });
  }

  Future<void> _search(String keyword) async {
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
      _keyword = '';
      _products = [];
      _errorMessage = null;
      _isLoading = false;
    });
  }

  void _retry() {
    _search(_keyword);
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
      appBar: AppBar(title: const Text('Search Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onKeywordChanged,
              onSubmitted: (value) => _search(value.trim()),
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Phone, laptop, watch...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
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
        message: 'Nhap ten san pham de tim kiem',
      );
    }

    if (_isLoading) {
      return const LoadingState(message: 'Dang tim kiem...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _retry);
    }

    if (_products.isEmpty) {
      return const EmptyState(message: 'Khong tim thay san pham phu hop');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return ProductItem(product: product, onTap: () => _openDetail(product));
      },
    );
  }
}
