import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/category_service.dart';
import '../widgets/app_state_widgets.dart';
import '../widgets/category_card.dart';
import 'product_by_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  final bool embeddedInNavigation;

  const CategoryScreen({super.key, this.embeddedInNavigation = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.loadCategories();
  }

  void _retry() {
    setState(() {
      _categoriesFuture = _categoryService.loadCategories();
    });
  }

  void _openCategory(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductByCategoryScreen(
          categoryName: category.name,
          slug: category.slug,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embeddedInNavigation,
        title: const Text('Danh mục'),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(message: 'Đang tải danh mục...');
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const EmptyState(message: 'Chưa có danh mục nào');
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width >= 600 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: width < 360 ? 164 : 174,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryCard(
                category: category,
                onTap: () => _openCategory(category),
              );
            },
          );
        },
      ),
    );
  }
}
