import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/app_state_widgets.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: LocalStorageService.getCurrentUser(),
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

        return _AccountContent(user: user);
      },
    );
  }
}

class _AccountContent extends StatelessWidget {
  final UserModel user;

  const _AccountContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: _AccountAvatar(user: user)),
        const SizedBox(height: 24),
        _AccountTile(
          icon: Icons.person_outline,
          title: 'Họ tên',
          value: user.fullName,
          colorScheme: colorScheme,
        ),
        _AccountTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: user.email,
          colorScheme: colorScheme,
        ),
        _AccountTile(
          icon: Icons.phone_outlined,
          title: 'Số điện thoại',
          value: user.phone.isEmpty ? 'Chưa cập nhật' : user.phone,
          colorScheme: colorScheme,
        ),
        _AccountTile(
          icon: Icons.location_on_outlined,
          title: 'Địa chỉ',
          value: user.address.isEmpty ? 'Chưa cập nhật' : user.address,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  final UserModel user;

  const _AccountAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl.trim();

    return ClipOval(
      child: AppNetworkImage(
        imageUrl: avatarUrl.isEmpty ? AppAssets.avatar : avatarUrl,
        width: 80,
        height: 80,
        fallbackIcon: Icons.person_rounded,
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ColorScheme colorScheme;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
