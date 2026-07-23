import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/config/app_flavor.dart';
import '../constants/app_assets.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_state_widgets.dart';
import 'edit_account_screen.dart';
import 'favourite_page.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'setting_screen.dart';
import 'sqlite/payment_history_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditAccountScreen()),
    );
    if (updated == true && mounted) {
      setState(_reloadUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        if (user == null) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            message: 'Chưa có dữ liệu người dùng',
          );
        }

        return _ProfileContent(user: user, onEdit: _openEditAccount);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const _ProfileContent({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 112),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(child: _ProfileAvatar(user: user)),
          ),
          const SizedBox(height: 18),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Chỉnh sửa tài khoản'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ProfileShortcut(
                  icon: Icons.receipt_long_outlined,
                  label: 'Đơn hàng',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentHistoryPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileShortcut(
                  icon: Icons.favorite_border,
                  label: 'Yêu thích',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavouritePage()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileShortcut(
                  icon: Icons.settings_outlined,
                  label: 'Cài đặt',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ProfileInfoTile(
            icon: Icons.badge_outlined,
            title: 'Họ tên',
            value: user.fullName,
          ),
          _ProfileInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          _ProfileInfoTile(
            icon: Icons.phone_outlined,
            title: 'Số điện thoại',
            value: user.phone.isEmpty ? 'Chưa cập nhật' : user.phone,
            onTap: user.phone.isEmpty ? onEdit : null,
          ),
          _ProfileInfoTile(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
            value: user.address.isEmpty ? 'Chưa cập nhật' : user.address,
            onTap: onEdit,
          ),
          const SizedBox(height: 10),
          _AccountMenuTile(
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            subtitle: 'Hoạt động đăng nhập',
            onTap: () => _openPage(
              context,
              title: 'Hoạt động đăng nhập',
              child: const HistoryScreen(),
            ),
          ),
          _AccountMenuTile(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () => _openPage(
              context,
              title: 'Cài đặt',
              child: const SettingScreen(),
            ),
          ),
          _AccountMenuTile(
            icon: Icons.info_outline,
            title: 'Giới thiệu ứng dụng',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppBrand.name,
              applicationVersion: '1.0.0',
            ),
          ),
          _AccountMenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách quyền riêng tư',
            onTap: () => _showLegalInformation(
              context,
              'Chính sách quyền riêng tư',
              'Ứng dụng chỉ sử dụng dữ liệu tài khoản và đơn hàng để cung cấp '
                  'các chức năng mua sắm. Dữ liệu đăng nhập được Firebase '
                  'Authentication bảo vệ.',
            ),
          ),
          _AccountMenuTile(
            icon: Icons.description_outlined,
            title: 'Điều khoản sử dụng',
            onTap: () => _showLegalInformation(
              context,
              'Điều khoản sử dụng',
              'Khi sử dụng ứng dụng, bạn đồng ý cung cấp thông tin chính xác '
                  'và chịu trách nhiệm bảo vệ tài khoản của mình.',
            ),
          ),
          _AccountMenuTile(
            icon: Icons.logout_rounded,
            title: 'Đăng xuất',
            onTap: () => _logout(context),
          ),
          _AccountMenuTile(
            icon: Icons.delete_forever_outlined,
            title: 'Xóa tài khoản',
            destructive: true,
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }

  void _openPage(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: child,
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    await LocalStorageService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tài khoản?'),
        content: const Text(
          'Thao tác này xóa tài khoản đăng nhập và không thể hoàn tác. '
          'Firebase có thể yêu cầu bạn đăng nhập lại trước khi xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa tài khoản'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw FirebaseAuthException(code: 'no-current-user');
      await user.delete();
      await LocalStorageService.logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      final message = error.code == 'requires-recent-login'
          ? 'Vui lòng đăng nhập lại trước khi xóa tài khoản.'
          : 'Không thể xóa tài khoản: ${error.message ?? error.code}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showLegalInformation(
    BuildContext context,
    String title,
    String content,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final UserModel user;

  const _ProfileAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl.trim();

    return AppNetworkImage(
      imageUrl: avatarUrl.isEmpty ? AppAssets.avatar : avatarUrl,
      width: 116,
      height: 116,
      fit: BoxFit.cover,
      fallbackIcon: Icons.person_rounded,
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _AccountMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = destructive ? colors.error : colors.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: destructive ? colors.error : colors.primary),
        title: Text(
          title,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Icon(Icons.chevron_right_rounded, color: foreground),
        onTap: onTap,
      ),
    );
  }
}
