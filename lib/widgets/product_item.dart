import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductItem({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: _ProductImage(source: product.thumbnail),
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
                          fontWeight: FontWeight.w800,
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
                          fontWeight: FontWeight.w900,
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
                            label: 'Stock ${product.stock}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String source;

  const _ProductImage({required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colorScheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _ImageFallback(colorScheme: colorScheme);
        },
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _ImageFallback(colorScheme: colorScheme);
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ImageFallback({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colorScheme.primary,
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
