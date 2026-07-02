import 'package:flutter/material.dart';

import 'core/theme/theme_controller.dart';
import 'screens/edit_account_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedThemeMode();
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Shop App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/main': (_) => const MainScreen(),
            '/history': (_) => const HistoryScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/edit-account': (_) => const EditAccountScreen(),
            '/settings': (_) => const SettingScreen(),
          },
        );
      },
    );
  }
}

@Deprecated('Use ShopApp instead.')
class Bai2App extends ShopApp {
  const Bai2App({super.key});
}
