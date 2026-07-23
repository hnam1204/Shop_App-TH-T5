import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/sqlite_category.dart';
import '../../models/sqlite_product.dart';
import '../../models/app_product_snapshot.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favourite_provider.dart';
import '../../services/sqlite_category_service.dart';
import '../../services/sqlite_product_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_state_widgets.dart';
import '../../widgets/cart_badge_icon.dart';
import '../cart_page.dart';

class SqliteProductPage extends ConsumerStatefulWidget {
  const SqliteProductPage({super.key});

  @override
  ConsumerState<SqliteProductPage> createState() => _SqliteProductPageState();
}

class _SqliteProductPageState extends ConsumerState<SqliteProductPage> {
  final SqliteProductService _productService = SqliteProductService();
  final SqliteCategoryService _categoryService = SqliteCategoryService();
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  List<SqliteProduct> _products = const [];
  List<SqliteCategory> _categories = const [];
  int? _selectedCategoryId;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await _categoryService.getAllCategories();
      final selectedCategoryId = _selectedCategoryId;
      final products = selectedCategoryId == null
          ? await _productService.getAllProducts()
          : await _productService.getProductsByCategory(selectedCategoryId);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _products = products;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _selectCategory(int? categoryId) async {
    setState(() => _selectedCategoryId = categoryId);
    await _load();
  }

  Future<void> _openForm([SqliteProduct? product]) async {
    if (_categories.isEmpty) {
      _showMessage('Hãy tạo ít nhất một danh mục trước.', isError: true);
      return;
    }
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ProductForm(
        service: _productService,
        categories: _categories,
        product: product,
      ),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _delete(SqliteProduct product) async {
    final id = product.id;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text('Bạn có chắc muốn xóa “${product.name}”?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _productService.deleteProduct(id);
      if (!mounted) return;
      _showMessage('Đã xóa sản phẩm.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _showMessage(_message(error), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _message(Object error) {
    if (error is ProductValidationException) return error.message;
    return 'Không thể xử lý sản phẩm. Vui lòng thử lại.';
  }

  Future<void> _addToCart(SqliteProduct product) async {
    try {
      await ref
          .read(cartProvider.notifier)
          .addProduct(AppProductSnapshot.fromWeek8(product));
      if (!mounted) return;
      _showMessage('Đã thêm ${product.name} vào giỏ hàng.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Không thể thêm sản phẩm vào giỏ.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm SQLite'),
        actions: [
          CartBadgeIcon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _CategoryFilter(
              categories: _categories,
              selectedId: _selectedCategoryId,
              onSelected: _selectCategory,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingState(message: 'Đang tải sản phẩm...');
    }
    final error = _error;
    if (error != null) {
      return ErrorState(message: 'Không thể tải sản phẩm.', onRetry: _load);
    }
    if (_products.isEmpty) {
      return const EmptyState(
        message: 'Chưa có sản phẩm phù hợp.',
        icon: Icons.inventory_2_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth < 380 ? 0.57 : 0.65,
            ),
            itemCount: _products.length,
            itemBuilder: (_, index) {
              final product = _products[index];
              final appProduct = AppProductSnapshot.fromWeek8(product);
              final isFavourite = ref.watch(
                isFavouriteProvider(appProduct.compositeKey),
              );
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: AppNetworkImage(
                        imageUrl: product.image,
                        fallbackIcon: Icons.shopping_bag_outlined,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.categoryName ?? 'Không có danh mục',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _currency.format(product.price),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (product.description.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              product.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                tooltip: isFavourite
                                    ? 'Bỏ yêu thích'
                                    : 'Thêm vào yêu thích',
                                onPressed: () => ref
                                    .read(favouriteProvider.notifier)
                                    .toggle(appProduct),
                                icon: Icon(
                                  isFavourite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Thêm vào giỏ',
                                onPressed: () => _addToCart(product),
                                icon: const Icon(
                                  Icons.add_shopping_cart_rounded,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Sửa',
                                onPressed: () => _openForm(product),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Xóa',
                                onPressed: () => _delete(product),
                                icon: const Icon(Icons.delete_outline),
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
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final List<SqliteCategory> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: selectedId == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text(category.name),
              selected: selectedId == category.id,
              onSelected: (_) => onSelected(category.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final SqliteProductService service;
  final List<SqliteCategory> categories;
  final SqliteProduct? product;

  const _ProductForm({
    required this.service,
    required this.categories,
    this.product,
  });

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageController;
  late final TextEditingController _descriptionController;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name);
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    _imageController = TextEditingController(text: product?.image);
    _descriptionController = TextEditingController(text: product?.description);
    _categoryId = product?.categoryId ?? widget.categories.first.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (_saving || form == null || !form.validate()) return;
    final categoryId = _categoryId;
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (categoryId == null || price == null) return;
    setState(() => _saving = true);
    try {
      final current = widget.product;
      if (current == null) {
        await widget.service.createProduct(
          name: _nameController.text,
          price: price,
          image: _imageController.text,
          description: _descriptionController.text,
          categoryId: categoryId,
        );
      } else {
        await widget.service.updateProduct(
          SqliteProduct(
            id: current.id,
            name: _nameController.text,
            price: price,
            image: _imageController.text,
            description: _descriptionController.text,
            categoryId: categoryId,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final message = error is ProductValidationException
          ? error.message
          : 'Không thể lưu sản phẩm. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Vui lòng nhập tên sản phẩm.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Giá',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final price = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (price == null) return 'Giá không hợp lệ.';
                  if (price < 0) return 'Giá không được âm.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categories
                    .where((category) => category.id != null)
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn danh mục.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL hoặc asset ảnh (không bắt buộc)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Đang lưu...' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
