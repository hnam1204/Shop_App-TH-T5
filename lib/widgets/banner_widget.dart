import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'app_network_image.dart';

class BannerCarousel extends StatelessWidget {
  final List<String> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colorScheme = Theme.of(context).colorScheme;

    return CarouselSlider(
      options: CarouselOptions(
        height: width < 390 ? 170 : 205,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        enlargeFactor: 0.18,
      ),
      items: banners.map((image) {
        return Builder(
          builder: (context) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  fallbackIcon: Icons.shopping_bag_outlined,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
