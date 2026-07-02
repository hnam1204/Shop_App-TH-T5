class Category {
  final int id;
  final String name;
  final String image;
  final String slug;

  const Category({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    return Category(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: name,
      image: json['image']?.toString() ?? '',
      slug: json['slug']?.toString().trim().isNotEmpty == true
          ? json['slug'].toString()
          : slugFromName(name),
    );
  }

  static String slugFromName(String name) {
    const slugs = {
      'Beauty': 'beauty',
      'Fragrances': 'fragrances',
      'Furniture': 'furniture',
      'Groceries': 'groceries',
      'Home Decoration': 'home-decoration',
      'Kitchen Accessories': 'kitchen-accessories',
      'Laptops': 'laptops',
      'Men Shirts': 'mens-shirts',
      'Men Shoes': 'mens-shoes',
      'Men Watches': 'mens-watches',
      'Mobile Accessories': 'mobile-accessories',
      'Motorcycle': 'motorcycle',
      'Skin Care': 'skin-care',
      'Smartphones': 'smartphones',
      'Sports Accessories': 'sports-accessories',
      'Sunglasses': 'sunglasses',
      'Tablets': 'tablets',
      'Tops': 'tops',
      'Vehicle': 'vehicle',
      'Women Bags': 'womens-bags',
      'Women Dresses': 'womens-dresses',
      'Women Jewellery': 'womens-jewellery',
      'Women Shoes': 'womens-shoes',
      'Women Watches': 'womens-watches',
    };

    return slugs[name] ?? name.trim().toLowerCase().replaceAll(' ', '-');
  }
}
