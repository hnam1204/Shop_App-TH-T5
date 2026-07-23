import 'package:flutter/material.dart';

import '../data/mockdata.dart';
import '../widgets/banner_widget.dart';
import '../widgets/category_card.dart';
import 'product_by_category_screen.dart';
import 'product_search_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onViewProducts;
  final VoidCallback onViewProfile;

  const HomeScreen({
    super.key,
    required this.onViewProducts,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào,',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn muốn mua gì hôm nay?',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductSearchScreen(),
                      ),
                    );
                  },
                  child: IgnorePointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tìm kiếm sản phẩm',
                        hintText: 'Điện thoại, laptop, đồng hồ...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: Icon(
                          Icons.tune_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const BannerCarousel(banners: MockData.banners),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: _SectionHeader(
              title: 'Danh mục',
              actionText: '${MockData.categories.length} mục',
            ),
          ),
          SizedBox(
            height: width >= 600 ? 176 : 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: MockData.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final category = MockData.categories[index];
                return SizedBox(
                  width: width >= 600 ? 190 : 150,
                  child: CategoryCard(
                    category: category,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductByCategoryScreen(
                            categoryName: category.name,
                            slug: category.slug,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
            child: _SectionHeader(
              title: 'Sản phẩm nổi bật',
              actionText: 'Xem tất cả',
              onActionTap: onViewProducts,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khám phá bộ sưu tập mới',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Danh sách sản phẩm được cập nhật liên tục.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: onViewProducts,
                          child: const Text('Xem sản phẩm'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: 54,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText != null)
          TextButton(onPressed: onActionTap, child: Text(actionText!)),
      ],
    );
  }
}
