import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/config/app_flavor.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNextScreen();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(Duration.zero);
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: isLoggedIn ? const MainScreen() : const LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppBrand.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppBrand.tagline,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.78),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
