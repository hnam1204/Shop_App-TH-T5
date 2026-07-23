import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import 'app_network_image.dart';

enum AppPage {
  home,
  allProducts,
  categories,
  products,
  search,
  favourites,
  profile,
  settings,
  about,
  productsHive,
  cartHive,
  categoriesSqlite,
  productsSqlite,
  orderHistory,
}

class CustomDrawer extends StatefulWidget {
  final AppPage? currentPage;
  final ValueChanged<AppPage> onNavigate;

  const CustomDrawer({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _reloadUser();
  }

  void _reloadUser() {
    _userFuture = LocalStorageService.getCurrentUser();
  }

  void _handleNavigation(AppPage page) {
    Navigator.pop(context);
    if (widget.currentPage == page) return;
    widget.onNavigate(page);
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await AuthService().logout();
    await LocalStorageService.logout();
    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final menuItems = const [
      _DrawerMenuItem(
        page: AppPage.home,
        title: 'Danh mục',
        icon: Icons.category_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.allProducts,
        title: 'Tất cả sản phẩm',
        icon: Icons.shopping_bag_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.categories,
        title: 'Danh mục sản phẩm',
        icon: Icons.dashboard_customize_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.products,
        title: 'Sản phẩm',
        icon: Icons.storefront_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.search,
        title: 'Tìm kiếm',
        icon: Icons.search_rounded,
      ),
      _DrawerMenuItem(
        page: AppPage.favourites,
        title: 'Yêu thích',
        icon: Icons.favorite_border,
      ),
      _DrawerMenuItem(
        page: AppPage.profile,
        title: 'Tài khoản của tôi',
        icon: Icons.manage_accounts_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.settings,
        title: 'Cài đặt',
        icon: Icons.settings_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.productsHive,
        title: 'Sản phẩm Hive',
        icon: Icons.inventory_2_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.cartHive,
        title: 'Giỏ hàng Hive',
        icon: Icons.shopping_cart_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.categoriesSqlite,
        title: 'Danh mục SQLite',
        icon: Icons.account_tree_outlined,
        sectionTitle: 'LOCAL DATABASE — SQLITE',
      ),
      _DrawerMenuItem(
        page: AppPage.productsSqlite,
        title: 'Sản phẩm SQLite',
        icon: Icons.storage_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.orderHistory,
        title: 'Lịch sử hóa đơn',
        icon: Icons.receipt_long_outlined,
      ),
      _DrawerMenuItem(
        page: AppPage.about,
        title: 'Giới thiệu ứng dụng',
        icon: Icons.info_outline,
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _DrawerUserHeader(
                colorScheme: colorScheme,
                userFuture: _userFuture,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                itemCount: menuItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == menuItems.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: _DrawerTile(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        isLogout: true,
                        onTap: _logout,
                      ),
                    );
                  }

                  final item = menuItems[index];
                  final isSelected = widget.currentPage == item.page;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.sectionTitle != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 18, 12, 8),
                          child: Text(
                            item.sectionTitle ?? '',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _DrawerTile(
                          icon: item.icon,
                          title: item.title,
                          selected: isSelected,
                          onTap: () => _handleNavigation(item.page),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem {
  final AppPage page;
  final String title;
  final IconData icon;
  final String? sectionTitle;

  const _DrawerMenuItem({
    required this.page,
    required this.title,
    required this.icon,
    this.sectionTitle,
  });
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final bool isLogout;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isLogout
        ? colorScheme.error
        : selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final backgroundColor = isLogout
        ? colorScheme.error.withValues(alpha: 0.08)
        : selected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: foregroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: isLogout || selected
                      ? foregroundColor
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerUserHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  final Future<UserModel?> userFuture;

  const _DrawerUserHeader({
    required this.colorScheme,
    required this.userFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DrawerHeader(
            decoration: _headerDecoration(colorScheme),
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.onPrimary),
            ),
          );
        }

        final user = snapshot.data;
        return UserAccountsDrawerHeader(
          margin: EdgeInsets.zero,
          decoration: _headerDecoration(colorScheme),
          accountName: Text(
            user?.fullName.isNotEmpty == true ? user!.fullName : 'Khách',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          accountEmail: Text(
            user?.email.isNotEmpty == true ? user!.email : 'Chưa lưu email',
          ),
          currentAccountPicture: _DrawerAvatar(user: user),
        );
      },
    );
  }

  BoxDecoration _headerDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [colorScheme.primary, colorScheme.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  final UserModel? user;

  const _DrawerAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl.trim() ?? '';

    return ClipOval(
      child: AppNetworkImage(
        imageUrl: avatarUrl.isEmpty ? AppAssets.avatar : avatarUrl,
        width: 72,
        height: 72,
        fallbackIcon: Icons.person_rounded,
      ),
    );
  }
}
