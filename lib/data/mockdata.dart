import '../constants/app_assets.dart';
import '../models/category.dart';
import '../models/product.dart';

class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String birthday;
  final String avatar;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthday,
    required this.avatar,
  });
}

class MockData {
  MockData._();

  static const List<String> banners = [
    AppAssets.banner1,
    AppAssets.banner2,
    AppAssets.banner3,
    AppAssets.banner4,
    AppAssets.banner5,
  ];

  static const List<Category> categories = [
    Category(
      id: 1,
      name: 'Smartphones',
      image: 'iphone.png',
      slug: 'smartphones',
    ),
    Category(id: 2, name: 'Laptops', image: 'laptop.png', slug: 'laptops'),
    Category(
      id: 3,
      name: 'Men Watches',
      image: 'watch.png',
      slug: 'mens-watches',
    ),
    Category(id: 4, name: 'Tablets', image: 'ipad.jpg', slug: 'tablets'),
  ];

  static const List<Product> products = [
    Product(
      id: 1,
      title: 'iPhone 16 Pro Max',
      description: 'Flagship phone with a sharp display and strong camera.',
      category: 'smartphones',
      price: 34990000,
      discountPercentage: 0,
      rating: 4.8,
      stock: 20,
      brand: 'Apple',
      thumbnail: AppAssets.iphone16,
      images: [AppAssets.iphone16],
    ),
    Product(
      id: 2,
      title: 'Samsung Galaxy S25 Ultra',
      description: 'Premium Android phone with a modern design.',
      category: 'smartphones',
      price: 31990000,
      discountPercentage: 0,
      rating: 4.7,
      stock: 18,
      brand: 'Samsung',
      thumbnail: AppAssets.samsungS25,
      images: [AppAssets.samsungS25],
    ),
    Product(
      id: 3,
      title: 'MacBook Air M3',
      description: 'Light laptop for study, work, and daily productivity.',
      category: 'laptops',
      price: 27990000,
      discountPercentage: 0,
      rating: 4.9,
      stock: 10,
      brand: 'Apple',
      thumbnail: AppAssets.macbookAirM3,
      images: [AppAssets.macbookAirM3],
    ),
    Product(
      id: 4,
      title: 'Dell XPS 13 Plus',
      description: 'Compact ultrabook with a clean premium design.',
      category: 'laptops',
      price: 36990000,
      discountPercentage: 0,
      rating: 4.6,
      stock: 12,
      brand: 'Dell',
      thumbnail: AppAssets.dellXps,
      images: [AppAssets.dellXps],
    ),
    Product(
      id: 5,
      title: 'Apple Watch Series 10',
      description: 'Smart watch for health tracking and quick notifications.',
      category: 'mens-watches',
      price: 11990000,
      discountPercentage: 0,
      rating: 4.6,
      stock: 22,
      brand: 'Apple',
      thumbnail: AppAssets.appleWatch,
      images: [AppAssets.appleWatch],
    ),
    Product(
      id: 6,
      title: 'iPad Air M2',
      description: 'Thin tablet for notes, online learning, and entertainment.',
      category: 'tablets',
      price: 16990000,
      discountPercentage: 0,
      rating: 4.7,
      stock: 14,
      brand: 'Apple',
      thumbnail: AppAssets.ipadAir,
      images: [AppAssets.ipadAir],
    ),
  ];

  static const UserProfile profile = UserProfile(
    fullName: 'Nguyen Hai Nam',
    email: 'hnam12042006@gmail.com',
    phone: '037 905 2767',
    gender: 'Nam',
    birthday: '12/04/2006',
    avatar: AppAssets.avatar,
  );
}
