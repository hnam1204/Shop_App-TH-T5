import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_controller.dart';
import 'constants/app_hive_constants.dart';
import 'firebase_options.dart';
import 'screens/edit_account_screen.dart';
import 'screens/history_screen.dart';
import 'screens/cart_page.dart';
import 'screens/hive_product_page.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox(AppHiveConstants.productsBox);
  await Hive.openBox(AppHiveConstants.cartBox);
  await Hive.openBox(AppHiveConstants.favouritesBox);
  await loadSavedThemeMode();
  runApp(const ProviderScope(child: ShopApp()));
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
            '/products-hive': (_) => const HiveProductPage(),
            '/cart-hive': (_) => const CartPage(),
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
