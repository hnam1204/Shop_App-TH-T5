import 'package:flutter/material.dart';

import '../../models/sqlite_category.dart';
import '../../services/sqlite_category_service.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/app_state_widgets.dart';
import '../../widgets/custom_text_field.dart';

class SqliteCategoryPage extends StatefulWidget {
  const SqliteCategoryPage({super.key});

  @override
  State<SqliteCategoryPage> createState() => _SqliteCategoryPageState();
}

class _SqliteCategoryPageState extends State<SqliteCategoryPage> {
  final SqliteCategoryService _service = SqliteCategoryService();
  List<SqliteCategory> _categories = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final categories = await _service.getAllCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
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

  Future<void> _openForm([SqliteCategory? category]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CategoryForm(service: _service, category: category),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _delete(SqliteCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Bạn có chắc muốn xóa “${category.name}”?'),
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
    final categoryId = category.id;
    if (confirmed != true || categoryId == null) return;
    try {
      await _service.deleteCategory(categoryId);
      if (!mounted) return;
      _showMessage('Đã xóa danh mục.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _showMessage(_message(error), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _message(Object error) {
    if (error is CategoryValidationException) return error.message;
    return 'Không thể xử lý danh mục. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục SQLite')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingState(message: 'Đang tải danh mục...');
    }
    final error = _error;
    if (error != null) {
      return ErrorState(message: 'Không thể tải danh mục.', onRetry: _load);
    }
    if (_categories.isEmpty) {
      return const EmptyState(
        message: 'Chưa có danh mục. Hãy tạo danh mục đầu tiên.',
        icon: Icons.category_outlined,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: AppNetworkImage(
                imageUrl: category.image,
                width: 58,
                height: 58,
                borderRadius: BorderRadius.circular(12),
                fallbackIcon: Icons.category_outlined,
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('ID: ${category.id}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _openForm(category);
                  if (value == 'delete') _delete(category);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  final SqliteCategoryService service;
  final SqliteCategory? category;

  const _CategoryForm({required this.service, this.category});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _imageController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _imageController = TextEditingController(text: widget.category?.image);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final formState = _formKey.currentState;
    if (_saving || formState == null || !formState.validate()) return;
    setState(() => _saving = true);
    try {
      final current = widget.category;
      if (current == null) {
        await widget.service.createCategory(
          name: _nameController.text,
          image: _imageController.text,
        );
      } else {
        await widget.service.updateCategory(
          SqliteCategory(
            id: current.id,
            name: _nameController.text,
            image: _imageController.text,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      final message = error is CategoryValidationException
          ? error.message
          : 'Không thể lưu danh mục. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.category == null ? 'Thêm danh mục' : 'Sửa danh mục',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _nameController,
                label: 'Tên danh mục',
                icon: Icons.category_outlined,
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Vui lòng nhập tên danh mục.'
                    : null,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _imageController,
                label: 'URL hoặc đường dẫn asset (không bắt buộc)',
                icon: Icons.image_outlined,
                textInputAction: TextInputAction.done,
                validator: (_) => null,
              ),
              const SizedBox(height: 22),
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
