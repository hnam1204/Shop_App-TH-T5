import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_state_widgets.dart';
import 'edit_account_screen.dart';

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
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 28),
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
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Chỉnh sửa tài khoản'),
            ),
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
          ),
          _ProfileInfoTile(
            icon: Icons.location_on_outlined,
            title: 'Địa chỉ',
            value: user.address.isEmpty ? 'Chưa cập nhật' : user.address,
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

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
    );
  }
}
