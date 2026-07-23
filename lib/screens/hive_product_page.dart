import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_product_snapshot.dart';
import '../models/hive_product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../services/hive_product_service.dart';
import '../services/hive_cart_service.dart';
import '../widgets/cart_badge_icon.dart';
import 'cart_page.dart';

class HiveProductPage extends ConsumerStatefulWidget {
  const HiveProductPage({super.key});

  @override
  ConsumerState<HiveProductPage> createState() => _HiveProductPageState();
}

class _HiveProductPageState extends ConsumerState<HiveProductPage> {
  final HiveProductService _productService = HiveProductService();
  final HiveCartService _cartService = HiveCartService();

  List<HiveProductModel> _products = [];
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final allProducts = _productService.getAllProducts();
    if (allProducts.isEmpty) {
      await _productService.seedSampleProductsIfEmpty();
    }
    setState(() {
      _products = _productService.searchProducts(_searchKeyword);
    });
  }

  void _onSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      _products = _productService.searchProducts(_searchKeyword);
    });
  }

  Future<void> _addToCart(HiveProductModel product) async {
    await ref
        .read(cartProvider.notifier)
        .addProduct(AppProductSnapshot.fromHive(product));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng')));
  }

  Future<void> _deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    await _loadProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa sản phẩm')));
  }

  void _showProductForm({HiveProductModel? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ProductForm(
          initialProduct: product,
          onSave: (newProduct) async {
            if (product == null) {
              await _productService.addProduct(newProduct);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm sản phẩm')),
                );
              }
            } else {
              await _productService.updateProduct(newProduct);
              await _cartService.updateCartProductDetails(newProduct);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật sản phẩm')),
                );
              }
            }
            await _loadProducts();
          },
        );
      },
    );
  }

  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products Hive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Quay lại',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        actions: [
          CartBadgeIcon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              ).then((_) => _loadProducts());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('Không có sản phẩm nào.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final appProduct = AppProductSnapshot.fromHive(product);
                        final isFavourite = ref.watch(
                          isFavouriteProvider(appProduct.compositeKey),
                        );
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.category,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(product.price),
                                        style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kho: ${product.stock}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: isFavourite
                                              ? 'Bỏ yêu thích'
                                              : 'Thêm vào yêu thích',
                                          icon: Icon(
                                            isFavourite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: 20,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () => ref
                                              .read(favouriteProvider.notifier)
                                              .toggle(appProduct),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blueGrey,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () => _showProductForm(
                                            product: product,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.redAccent,
                                          ),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () =>
                                              _deleteProduct(product.id),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      onPressed: () => _addToCart(product),
                                      child: const Text('Thêm vào giỏ'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final HiveProductModel? initialProduct;
  final Function(HiveProductModel) onSave;

  const _ProductForm({this.initialProduct, required this.onSave});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _categoryController;
  late TextEditingController _descController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProduct?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialProduct?.price.toString() ?? '',
    );
    _imageController = TextEditingController(
      text: widget.initialProduct?.imageUrl ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.initialProduct?.category ?? '',
    );
    _descController = TextEditingController(
      text: widget.initialProduct?.description ?? '',
    );
    _stockController = TextEditingController(
      text: widget.initialProduct?.stock.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final String id =
          widget.initialProduct?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final DateTime createdAt =
          widget.initialProduct?.createdAt ?? DateTime.now();

      final product = HiveProductModel(
        id: id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _categoryController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: _imageController.text.trim().isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageController.text.trim(),
        stock: int.tryParse(_stockController.text) ?? 0,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

      widget.onSave(product);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialProduct == null
                    ? 'Thêm Sản Phẩm Mới'
                    : 'Sửa Sản Phẩm',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Tên không được rỗng' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá (VNĐ)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nhập giá';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) {
                    return 'Giá phải > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Tồn kho'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Nhập số lượng';
                  if (int.tryParse(val) == null || int.parse(val) < 0) {
                    return 'Tồn kho >= 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Link ảnh (URL)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu Sản Phẩm',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
