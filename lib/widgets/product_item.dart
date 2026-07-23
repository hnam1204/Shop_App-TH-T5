import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import 'app_network_image.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavourite;
  final bool isFavourite;

  const ProductItem({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.onToggleFavourite,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: AppNetworkImage(
                      imageUrl: product.thumbnail,
                      fallbackIcon: Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        formatter.format(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _MetaText(
                            icon: Icons.star_rounded,
                            label: product.rating.toStringAsFixed(1),
                          ),
                          _MetaText(
                            icon: Icons.inventory_2_outlined,
                            label: 'Kho ${product.stock}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onToggleFavourite != null)
                      IconButton(
                        tooltip: isFavourite
                            ? 'Bỏ yêu thích'
                            : 'Thêm vào yêu thích',
                        onPressed: onToggleFavourite,
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                    IconButton.filledTonal(
                      tooltip: 'Thêm vào giỏ hàng',
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart_rounded),
                    ),
                    const SizedBox(height: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaText({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
