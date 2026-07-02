import 'package:flutter/material.dart';
import '../tabs/account_tab.dart';
import '../tabs/general_tab.dart';
import '../tabs/notification_tab.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: colorScheme.surface,
            child: TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Account'),
                Tab(text: 'Notification'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [GeneralTab(), AccountTab(), NotificationTab()],
            ),
          ),
        ],
      ),
    );
  }
}
