import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_flavor.dart';
import '../providers/cart_provider.dart';
import '../providers/favourite_provider.dart';
import '../widgets/custom_drawer.dart';
import 'cart_page.dart';
import 'category_screen.dart';
import 'favourite_page.dart';
import 'firebases/categoryfb_page.dart';
import 'firebases/productfb_page.dart';
import 'home_screen.dart';
import 'product_screen.dart';
import 'product_search_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';
import 'sqlite/payment_history_page.dart';
import 'sqlite/sqlite_category_page.dart';
import 'sqlite/sqlite_product_page.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0})
    : assert(initialIndex >= 0 && initialIndex <= 4);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
  }

  AppPage? get _currentDrawerPage {
    return switch (_selectedIndex) {
      0 => AppPage.home,
      2 => AppPage.favourites,
      4 => AppPage.profile,
      _ => null,
    };
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _push(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _handleDrawerNavigate(AppPage page) {
    switch (page) {
      case AppPage.home:
        _selectTab(0);
      case AppPage.allProducts:
        _push(const ProductScreen());
      case AppPage.categories:
        _push(const CategoryFbPage());
      case AppPage.products:
        _push(const ProductFbPage());
      case AppPage.search:
        _push(const ProductSearchScreen());
      case AppPage.favourites:
        _selectTab(2);
      case AppPage.profile:
        _selectTab(4);
      case AppPage.settings:
        _push(
          const Scaffold(
            appBar: _RouteAppBar(title: 'Cài đặt'),
            body: SettingScreen(),
          ),
        );
      case AppPage.productsHive:
        Navigator.pushNamed(context, '/products-hive');
      case AppPage.cartHive:
        Navigator.pushNamed(context, '/cart-hive');
      case AppPage.categoriesSqlite:
        _push(const SqliteCategoryPage());
      case AppPage.productsSqlite:
        _push(const SqliteProductPage());
      case AppPage.orderHistory:
        _push(const PaymentHistoryPage());
      case AppPage.about:
        showAboutDialog(
          context: context,
          applicationName: AppBrand.name,
          applicationVersion: '1.0.0',
          applicationIcon: Icon(
            Icons.shopping_bag,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = !AppFlavorConfig.isStore;
    final drawer = isDemo
        ? CustomDrawer(
            currentPage: _currentDrawerPage,
            onNavigate: _handleDrawerNavigate,
          )
        : null;

    final screens = <Widget>[
      Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isDemo
              ? Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Mở menu bài học',
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                )
              : null,
          title: const Text(AppBrand.name),
        ),
        drawer: drawer,
        body: HomeScreen(
          onViewProducts: () => _push(const ProductScreen()),
          onViewProfile: () => _selectTab(4),
        ),
      ),
      const CategoryScreen(embeddedInNavigation: true),
      const FavouritePage(embeddedInNavigation: true),
      const CartPage(embeddedInNavigation: true),
      const Scaffold(
        appBar: _RouteAppBar(title: 'Tài khoản', implyLeading: false),
        body: ProfileScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
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
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Danh mục',
            ),
            NavigationDestination(
              icon: _FavouriteNavigationIcon(),
              selectedIcon: _FavouriteNavigationIcon(selected: true),
              label: 'Yêu thích',
            ),
            NavigationDestination(
              icon: _CartNavigationIcon(),
              selectedIcon: _CartNavigationIcon(selected: true),
              label: 'Giỏ hàng',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}

class _FavouriteNavigationIcon extends ConsumerWidget {
  final bool selected;

  const _FavouriteNavigationIcon({this.selected = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favouriteCountProvider);
    return _NavigationBadge(
      count: count,
      semanticsLabel: 'Yêu thích, $count sản phẩm',
      icon: selected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    );
  }
}

class _CartNavigationIcon extends ConsumerWidget {
  final bool selected;

  const _CartNavigationIcon({this.selected = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartTotalQuantityProvider);
    return _NavigationBadge(
      count: count,
      semanticsLabel: 'Giỏ hàng, tổng $count sản phẩm',
      icon: selected
          ? Icons.shopping_cart_rounded
          : Icons.shopping_cart_outlined,
    );
  }
}

class _NavigationBadge extends StatelessWidget {
  final int count;
  final String semanticsLabel;
  final IconData icon;

  const _NavigationBadge({
    required this.count,
    required this.semanticsLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        backgroundColor: colors.error,
        textColor: colors.onError,
        child: Icon(icon),
      ),
    );
  }
}

class _RouteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool implyLeading;

  const _RouteAppBar({required this.title, this.implyLeading = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(automaticallyImplyLeading: implyLeading, title: Text(title));
  }
}
