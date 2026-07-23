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

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Product> products = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
  String _keyword = '';
  String _selectedFilter = 'all';
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
    _searchController.dispose();
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

  List<Product> get _visibleProducts {
    final keyword = _keyword.trim().toLowerCase();
    var items = products.where((product) {
      if (_selectedFilter == 'inStock' && product.stock <= 0) return false;
      if (keyword.isEmpty) return true;

      return product.title.toLowerCase().contains(keyword) ||
          product.category.toLowerCase().contains(keyword) ||
          product.brand.toLowerCase().contains(keyword);
    }).toList();

    switch (_selectedFilter) {
      case 'lowPrice':
        items.sort((a, b) => a.price.compareTo(b.price));
      case 'highPrice':
        items.sort((a, b) => b.price.compareTo(a.price));
      case 'rating':
        items.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading && products.isEmpty) {
      content = const LoadingState(message: 'Đang tải sản phẩm...');
    } else if (errorMessage != null && products.isEmpty) {
      content = ErrorState(
        message: errorMessage!,
        onRetry: () => _loadProducts(reset: true),
      );
    } else {
      final visibleProducts = _visibleProducts;

      content = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
          itemCount: visibleProducts.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _ProductHeader(
                controller: _searchController,
                keyword: _keyword,
                selectedFilter: _selectedFilter,
                onSearchChanged: (value) {
                  setState(() {
                    _keyword = value;
                  });
                },
                onClearSearch: () {
                  _searchController.clear();
                  setState(() {
                    _keyword = '';
                  });
                },
                onFilterChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                  });
                },
              );
            }

            if (visibleProducts.isEmpty && index == 1) {
              return const Padding(
                padding: EdgeInsets.only(top: 96),
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: 'Chưa có sản phẩm phù hợp',
                ),
              );
            }

            if (index == visibleProducts.length + 1) {
              if (isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: _loadProducts,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ),
                );
              }
              if (!hasMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Đã tải hết sản phẩm',
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

            final product = visibleProducts[index - 1];
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(child: content),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final TextEditingController controller;
  final String keyword;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onFilterChanged;

  const _ProductHeader({
    required this.controller,
    required this.keyword,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filters = const [
      ('all', 'Tất cả'),
      ('lowPrice', 'Giá thấp'),
      ('highPrice', 'Giá cao'),
      ('rating', 'Đánh giá cao'),
      ('inStock', 'Còn hàng'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sản phẩm',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Khám phá sản phẩm phù hợp với nhu cầu của bạn.',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              labelText: 'Tìm kiếm sản phẩm',
              hintText: 'Nhập tên, thương hiệu hoặc danh mục...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: keyword.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              return ChoiceChip(
                selected: selectedFilter == filter.$1,
                label: Text(filter.$2),
                onSelected: (_) => onFilterChanged(filter.$1),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
