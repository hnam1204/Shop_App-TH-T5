import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/menu_item.dart';
import '../models/user_model.dart';
import '../screens/category_screen.dart';
import '../screens/edit_account_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_search_screen.dart';
import '../services/local_storage_service.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onProductsTap;
  final VoidCallback onSettingsTap;

  const CustomDrawer({
    super.key,
    required this.onProductsTap,
    required this.onSettingsTap,
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

  Future<void> _openEditAccount() async {
    final navigator = Navigator.of(context);
    navigator.pop();
    final updated = await navigator.push<bool>(
      MaterialPageRoute(builder: (_) => const EditAccountScreen()),
    );
    if (updated == true && mounted) {
      setState(_reloadUser);
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
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

    final menuItems = [
      MenuItemModel(
        title: 'Categories',
        icon: Icons.category_outlined,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          );
        },
      ),
      MenuItemModel(
        title: 'Product All',
        icon: Icons.shopping_bag_outlined,
        onTap: () {
          Navigator.pop(context);
          widget.onProductsTap();
        },
      ),
      MenuItemModel(
        title: 'Search Product',
        icon: Icons.search_rounded,
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductSearchScreen()),
          );
        },
      ),
      MenuItemModel(
        title: 'Edit Account',
        icon: Icons.manage_accounts_outlined,
        onTap: _openEditAccount,
      ),
      MenuItemModel(
        title: 'Settings',
        icon: Icons.settings_outlined,
        onTap: () {
          Navigator.pop(context);
          widget.onSettingsTap();
        },
      ),
      MenuItemModel(
        title: 'About',
        icon: Icons.info_outline,
        onTap: () {
          Navigator.pop(context);
          showAboutDialog(
            context: context,
            applicationName: 'Shop App',
            applicationVersion: '1.0.0',
            applicationIcon: Icon(
              Icons.shopping_bag,
              size: 48,
              color: colorScheme.primary,
            ),
            children: const [
              Text(
                '\u0110\u00e2y l\u00e0 \u1ee9ng d\u1ee5ng th\u01b0\u01a1ng m\u1ea1i \u0111i\u1ec7n t\u1eed ph\u1ee5c v\u1ee5 \u0111\u1ed3 \u00e1n b\u00e0i t\u1eadp Navigation.',
              ),
            ],
          );
        },
      ),
      MenuItemModel(title: 'Logout', icon: Icons.logout, onTap: _logout),
    ];

    return Drawer(
      child: Column(
        children: [
          _DrawerUserHeader(colorScheme: colorScheme, userFuture: _userFuture),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  leading: Icon(item.icon, color: colorScheme.onSurfaceVariant),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: item.onTap,
                );
              },
            ),
          ),
        ],
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
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.onPrimary),
            ),
          );
        }

        final user = snapshot.data;
        return UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: colorScheme.primary),
          accountName: Text(
            user?.fullName.isNotEmpty == true ? user!.fullName : 'Guest',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          accountEmail: Text(
            user?.email.isNotEmpty == true ? user!.email : 'No email saved',
          ),
          currentAccountPicture: _DrawerAvatar(user: user),
        );
      },
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  final UserModel? user;

  const _DrawerAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatarUrl.trim() ?? '';

    if (avatarUrl.startsWith('http')) {
      return CircleAvatar(backgroundImage: NetworkImage(avatarUrl));
    }

    return const CircleAvatar(backgroundImage: AssetImage(AppAssets.avatar));
  }
}
