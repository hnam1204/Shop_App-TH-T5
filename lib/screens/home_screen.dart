import 'package:flutter/material.dart';

import '../data/mockdata.dart';
import '../widgets/banner_widget.dart';
import '../widgets/category_card.dart';
import 'product_by_category_screen.dart';

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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          const BannerCarousel(banners: MockData.banners),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${MockData.categories.length} items',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: MockData.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: width >= 600 ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: width < 360 ? 1 : 1.12,
              ),
              itemBuilder: (context, index) {
                final category = MockData.categories[index];
                return CategoryCard(
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.storefront_rounded),
                label: const Text('View Products'),
                onPressed: onViewProducts,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
