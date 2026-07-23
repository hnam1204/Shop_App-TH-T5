import 'package:flutter/material.dart';

import '../core/config/app_flavor.dart';
import '../core/theme/theme_controller.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  AppSettings _settings = const AppSettings();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await LocalStorageService.getSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _setTheme(ThemeMode mode) async {
    await setThemeMode(mode);
    if (mounted) setState(() {});
  }

  Future<void> _setLanguage(String language) async {
    final settings = _settings.copyWith(language: language);
    await LocalStorageService.saveSettings(settings);
    if (mounted) setState(() => _settings = settings);
  }

  Future<void> _setNotifications(bool value) async {
    final settings = _settings.copyWith(notificationEnabled: value);
    await LocalStorageService.saveSettings(settings);
    if (mounted) setState(() => _settings = settings);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
      children: [
        const _SettingsHeader('GIAO DIỆN'),
        Card(
          child: Column(
            children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, mode, _) => ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Chủ đề'),
                  subtitle: Text(_themeLabel(mode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _chooseTheme(context, mode),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Ngôn ngữ'),
                subtitle: Text(
                  _settings.language == 'Vietnamese'
                      ? 'Tiếng Việt'
                      : 'Tiếng Anh',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _chooseLanguage(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SettingsHeader('TÀI KHOẢN'),
        const Card(
          child: ListTile(
            leading: Icon(Icons.security_outlined),
            title: Text('Bảo mật'),
            subtitle: Text('Quản lý mật khẩu trong tài khoản Firebase'),
          ),
        ),
        const SizedBox(height: 20),
        const _SettingsHeader('ỨNG DỤNG'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Thông báo'),
                subtitle: const Text('Nhận cập nhật về đơn hàng'),
                value: _settings.notificationEnabled,
                onChanged: _setNotifications,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Giới thiệu'),
                subtitle: const Text('${AppBrand.name} · Phiên bản 1.0.0'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AppBrand.name,
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Theo hệ thống',
      ThemeMode.light => 'Sáng',
      ThemeMode.dark => 'Tối',
    };
  }

  Future<void> _chooseTheme(BuildContext context, ThemeMode current) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Theo hệ thống'),
              trailing: current == ThemeMode.system
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, ThemeMode.system),
            ),
            ListTile(
              title: const Text('Sáng'),
              trailing: current == ThemeMode.light
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, ThemeMode.light),
            ),
            ListTile(
              title: const Text('Tối'),
              trailing: current == ThemeMode.dark
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
    if (selected != null) await _setTheme(selected);
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Tiếng Việt'),
              onTap: () => Navigator.pop(context, 'Vietnamese'),
            ),
            ListTile(
              title: const Text('Tiếng Anh'),
              onTap: () => Navigator.pop(context, 'English'),
            ),
          ],
        ),
      ),
    );
    if (selected != null) await _setLanguage(selected);
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
