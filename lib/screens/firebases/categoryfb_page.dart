import 'package:flutter/material.dart';

import '../../models/categoryfb_model.dart';
import '../../services/categoryfb_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_state_widgets.dart';

class CategoryFbPage extends StatefulWidget {
  const CategoryFbPage({super.key});

  @override
  State<CategoryFbPage> createState() => _CategoryFbPageState();
}

class _CategoryFbPageState extends State<CategoryFbPage> {
  final CategoryFbService _service = CategoryFbService();
  final TextEditingController _searchController = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryFbModel> _filterCategories(List<CategoryFbModel> categories) {
    final keyword = _keyword.trim().toLowerCase();
    if (keyword.isEmpty) return categories;
    return categories
        .where((category) => category.name.toLowerCase().contains(keyword))
        .toList();
  }

  Future<void> _openForm({CategoryFbModel? category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final imageController = TextEditingController(
      text: category?.imageUrl ?? '',
    );
    final formKey = GlobalKey<FormState>();

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
                category == null ? 'Thêm danh mục' : 'Sửa danh mục',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên danh mục',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên danh mục';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: imageController,
                        decoration: const InputDecoration(
                          labelText: 'Liên kết hình ảnh hoặc asset',
                          hintText: 'assets/images/smartphones.jpg',
                          prefixIcon: Icon(Icons.image_outlined),
                        ),
                      ),
                    ],
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

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            final name = nameController.text.trim();
                            final imageUrl = imageController.text.trim();
                            if (category == null) {
                              await _service.addCategory(
                                name: name,
                                imageUrl: imageUrl,
                              );
                            } else {
                              await _service.updateCategory(
                                id: category.id,
                                name: name,
                                imageUrl: imageUrl,
                              );
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            _showMessage('Lưu danh mục thành công');
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
    imageController.dispose();
  }

  Future<void> _deleteCategory(CategoryFbModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa danh mục'),
        content: Text('Bạn có chắc muốn xóa "${category.name}" không?'),
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
      await _service.deleteCategory(category.id);
      _showMessage('Đã xóa danh mục');
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
      appBar: AppBar(title: const Text('Danh mục sản phẩm')),
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
                labelText: 'Tìm kiếm danh mục',
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
            child: StreamBuilder<List<CategoryFbModel>>(
              stream: _service.getCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Đang tải danh mục...');
                }

                if (snapshot.hasError) {
                  return ErrorState(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  );
                }

                final categories = _filterCategories(snapshot.data ?? []);
                if (categories.isEmpty) {
                  return const EmptyState(
                    icon: Icons.category_outlined,
                    message: 'Chưa có danh mục phù hợp',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 700
                        ? 3
                        : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: AppNetworkImage(
                                imageUrl: category.imageUrl,
                                fallbackIcon: Icons.category_outlined,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                            child: Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _openForm(category: category),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Sửa'),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Xóa',
                                  onPressed: () => _deleteCategory(category),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: colorScheme.error,
                                  ),
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
          ),
        ],
      ),
    );
  }
}
