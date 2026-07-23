import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/categoryfb_model.dart';
import '../../models/productfb_model.dart';
import '../../services/categoryfb_service.dart';
import '../../services/productfb_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_state_widgets.dart';

class ProductFbPage extends StatefulWidget {
  const ProductFbPage({super.key});

  @override
  State<ProductFbPage> createState() => _ProductFbPageState();
}

class _ProductFbPageState extends State<ProductFbPage> {
  final ProductFbService _productService = ProductFbService();
  final CategoryFbService _categoryService = CategoryFbService();
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND',
    decimalDigits: 0,
  );

  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductFbModel> _filterProducts(List<ProductFbModel> products) {
    final keyword = _keyword.trim().toLowerCase();
    if (keyword.isEmpty) return products;
    return products.where((product) {
      return product.name.toLowerCase().contains(keyword) ||
          product.categoryName.toLowerCase().contains(keyword);
    }).toList();
  }

  Future<void> _openForm({ProductFbModel? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final imageController = TextEditingController(
      text: product?.imageUrl ?? '',
    );
    final formKey = GlobalKey<FormState>();

    String selectedCategoryId = product?.categoryId ?? '';
    String selectedCategoryName = product?.categoryName ?? '';
    bool isAvailable = product?.isAvailable ?? true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SizedBox(
                width: 460,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên sản phẩm',
                            prefixIcon: Icon(Icons.shopping_bag_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tên sản phẩm';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          validator: (value) {
                            final price = double.tryParse(value?.trim() ?? '');
                            if (price == null || price <= 0) {
                              return 'Giá phải lớn hơn 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Liên kết hình ảnh hoặc asset',
                            hintText: 'assets/images/iphone16.png',
                            prefixIcon: Icon(Icons.image_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<CategoryFbModel>>(
                          stream: _categoryService.getCategories(),
                          builder: (context, snapshot) {
                            final categories = snapshot.data ?? [];
                            if (categories.isEmpty) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Hãy tạo danh mục trước',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              );
                            }

                            final hasSelected = categories.any(
                              (item) => item.id == selectedCategoryId,
                            );
                            final currentValue = hasSelected
                                ? selectedCategoryId
                                : null;

                            return DropdownButtonFormField<String>(
                              initialValue: currentValue,
                              decoration: const InputDecoration(
                                labelText: 'Danh mục',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                final category = categories.firstWhere(
                                  (item) => item.id == value,
                                );
                                setDialogState(() {
                                  selectedCategoryId = category.id;
                                  selectedCategoryName = category.name;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng chọn danh mục';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isAvailable,
                          title: const Text('Còn bán'),
                          onChanged: (value) {
                            setDialogState(() {
                              isAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final isValid =
                              formKey.currentState?.validate() ?? false;
                          if (!isValid) return;
                          if (selectedCategoryId.isEmpty) {
                            _showMessage('Vui lòng tạo và chọn danh mục');
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final price = double.parse(
                              priceController.text.trim(),
                            );
                            if (product == null) {
                              await _productService.addProduct(
                                name: nameController.text.trim(),
                                price: price,
                                description: descriptionController.text.trim(),
                                categoryId: selectedCategoryId,
                                categoryName: selectedCategoryName,
                                imageUrl: imageController.text.trim(),
                                isAvailable: isAvailable,
                              );
                            } else {
                              await _productService.updateProduct(
                                id: product.id,
                                name: nameController.text.trim(),
                                price: price,
                                description: descriptionController.text.trim(),
                                categoryId: selectedCategoryId,
                                categoryName: selectedCategoryName,
                                imageUrl: imageController.text.trim(),
                                isAvailable: isAvailable,
                              );
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            _showMessage('Lưu sản phẩm thành công');
                          } catch (error) {
                            if (!dialogContext.mounted) return;
                            setDialogState(() {
                              isSaving = false;
                            });
                            _showMessage('Lỗi: $error');
                          }
                        },
                  child: isSaving
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageController.dispose();
  }

  Future<void> _deleteProduct(ProductFbModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${product.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    try {
      await _productService.deleteProduct(product.id);
      _showMessage('Đã xóa sản phẩm');
    } catch (error) {
      _showMessage('Lỗi: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _keyword = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tìm theo tên sản phẩm hoặc danh mục',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _keyword = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProductFbModel>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Đang tải sản phẩm...');
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  );
                }

                final products = _filterProducts(snapshot.data ?? []);
                if (products.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'Chưa có sản phẩm phù hợp',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 92,
                                height: 92,
                                child: AppNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fallbackIcon: Icons.shopping_bag_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: product.isAvailable
                                              ? Colors.green.withValues(
                                                  alpha: 0.12,
                                                )
                                              : colorScheme.error.withValues(
                                                  alpha: 0.12,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          product.isAvailable
                                              ? 'Còn bán'
                                              : 'Tạm hết',
                                          style: TextStyle(
                                            color: product.isAvailable
                                                ? Colors.green.shade700
                                                : colorScheme.error,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    product.categoryName,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currencyFormat.format(product.price),
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (product.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () =>
                                            _openForm(product: product),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text('Sửa'),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        tooltip: 'Xóa',
                                        onPressed: () =>
                                            _deleteProduct(product),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
