import 'package:flutter/material.dart';
import '../core/theme/theme_controller.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

class GeneralTab extends StatefulWidget {
  const GeneralTab({super.key});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  AppSettings _settings = const AppSettings();
  bool _autoLogin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final results = await Future.wait<Object>([
      LocalStorageService.getSettings(),
      LocalStorageService.getLoginStatus(),
    ]);
    if (!mounted) return;
    setState(() {
      _settings = results[0] as AppSettings;
      _autoLogin = results[1] as bool;
      _isLoading = false;
    });
  }

  Future<void> _changeAutoLogin(bool value) async {
    if (value) {
      final user = await LocalStorageService.getUser();
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hay dang nhap voi Remember Me truoc'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    await LocalStorageService.saveLoginStatus(value);
    if (!mounted) return;
    setState(() {
      _autoLogin = value;
    });
  }

  Future<void> _changeDarkMode(bool value) async {
    final settings = _settings.copyWith(isDarkMode: value);
    setState(() {
      _settings = settings;
    });
    await setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _changeLanguage(String? value) async {
    if (value == null) return;
    final settings = _settings.copyWith(language: value);
    setState(() {
      _settings = settings;
    });
    await LocalStorageService.saveSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, themeMode, _) {
            final isDark = themeMode == ThemeMode.dark;
            return SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              value: isDark,
              onChanged: _changeDarkMode,
              secondary: const Icon(Icons.dark_mode_outlined),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text(
            'Language',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: DropdownButton<String>(
            value: _settings.language,
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'Vietnamese', child: Text('Vietnamese')),
            ],
            onChanged: _changeLanguage,
          ),
        ),
        SwitchListTile(
          title: const Text(
            'Auto Login',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          value: _autoLogin,
          onChanged: _changeAutoLogin,
          secondary: const Icon(Icons.login),
        ),
      ],
    );
  }
}
