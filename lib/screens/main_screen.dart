import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import 'setting_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onViewProducts: _openProducts,
        onViewProfile: () => _selectTab(2),
      ),
      const HistoryScreen(),
      const ProfileScreen(),
      const SettingScreen(),
    ];

    final titles = ['Home', 'History', 'Profile', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(Icons.person_rounded),
                  onPressed: () => _selectTab(2),
                ),
                const SizedBox(width: 6),
              ]
            : null,
      ),
      drawer: CustomDrawer(
        onProductsTap: _openProducts,
        onSettingsTap: () => _selectTab(3),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'HISTORY',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'SETTING',
          ),
        ],
      ),
    );
  }
}
