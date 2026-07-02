import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/local_storage_service.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await LocalStorageService.getSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _changeNotification(bool value) async {
    final settings = _settings.copyWith(notificationEnabled: value);
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
        SwitchListTile(
          title: const Text(
            'Notification',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          value: _settings.notificationEnabled,
          onChanged: _changeNotification,
          secondary: const Icon(Icons.notifications_active_outlined),
        ),
      ],
    );
  }
}
