import 'package:flutter/material.dart';

import '../widgets/cart_badge_icon.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/favourite_badge_icon.dart';
import 'cart_page.dart';
import 'favourite_page.dart';
import 'firebases/categoryfb_page.dart';
import 'firebases/productfb_page.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'product_screen.dart';
import 'product_search_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';
import 'sqlite/payment_history_page.dart';
import 'sqlite/sqlite_category_page.dart';
import 'sqlite/sqlite_product_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  AppPage? get _currentDrawerPage {
    switch (_selectedIndex) {
      case 0:
        return AppPage.home;
      case 2:
        return AppPage.profile;
      case 3:
        return AppPage.settings;
      default:
        return null;
    }
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductScreen()),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  void _openFavourites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavouritePage()),
    );
  }

  void _handleDrawerNavigate(AppPage page) {
    switch (page) {
      case AppPage.home:
        _selectTab(0);
      case AppPage.allProducts:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductScreen()),
        );
      case AppPage.categories:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryFbPage()),
        );
      case AppPage.products:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFbPage()),
        );
      case AppPage.search:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductSearchScreen()),
        );
      case AppPage.favourites:
        _openFavourites();
      case AppPage.profile:
        _selectTab(2);
      case AppPage.settings:
        _selectTab(3);
      case AppPage.productsHive:
        Navigator.pushNamed(context, '/products-hive');
      case AppPage.cartHive:
        Navigator.pushNamed(context, '/cart-hive');
      case AppPage.categoriesSqlite:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SqliteCategoryPage()),
        );
      case AppPage.productsSqlite:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SqliteProductPage()),
        );
      case AppPage.orderHistory:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentHistoryPage()),
        );
      case AppPage.about:
        showAboutDialog(
          context: context,
          applicationName: 'Shop App',
          applicationVersion: '1.0.0',
          applicationIcon: Icon(
            Icons.shopping_bag,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: const [
            Text(
              'Đây là ứng dụng thương mại điện tử phục vụ đồ án bài tập Navigation.',
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onViewProducts: _openProducts,
        onViewProfile: () => _selectTab(2),
      ),
      const HistoryScreen(),
      const ProfileScreen(),
      const SettingScreen(),
    ];

    final titles = ['Trang chủ', 'Lịch sử', 'Tài khoản', 'Cài đặt'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0) CartBadgeIcon(onPressed: _openCart),
          if (_selectedIndex == 0)
            FavouriteBadgeIcon(onPressed: _openFavourites),
          if (_selectedIndex == 0)
            IconButton(
              tooltip: 'Tài khoản',
              icon: const Icon(Icons.person_rounded),
              onPressed: () => _selectTab(2),
            ),
          const SizedBox(width: 6),
        ],
      ),
      drawer: CustomDrawer(
        currentPage: _currentDrawerPage,
        onNavigate: _handleDrawerNavigate,
      ),
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _selectedIndex, children: screens),
      ),
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Lịch sử',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }
}
