import 'package:flutter/material.dart';

import '../../services/local_storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> loadSavedThemeMode() async {
  themeNotifier.value = await LocalStorageService.getThemeMode();
}

Future<void> setThemeMode(ThemeMode mode) async {
  themeNotifier.value = mode;
  await LocalStorageService.saveThemeMode(mode);
}

const _seedColor = Color(0xFF4F46E5);

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: _seedColor,
    primary: _seedColor,
    secondary: const Color(0xFF06B6D4),
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F8FC),
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: _seedColor,
    foregroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: const Color(0xFFEFF6FF),
    elevation: 8,
    shadowColor: const Color(0x14000000),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          fontWeight: FontWeight.w700,
          color: _seedColor,
          fontSize: 12,
        );
      }
      return const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        fontSize: 12,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: _seedColor);
      }
      return const IconThemeData(color: Color(0xFF64748B));
    }),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _seedColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: const Color(0x554F46E5),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _seedColor, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
    ),
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: _seedColor,
    primary: _seedColor,
    secondary: const Color(0xFF06B6D4),
    surface: const Color(0xFF1E1E2C),
    onSurface: const Color(0xFFE2E8F0),
  ),
  scaffoldBackgroundColor: const Color(0xFF12121A),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Color(0xFF1E1E2C),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1E1E2C),
    indicatorColor: _seedColor.withValues(alpha: 0.28),
    elevation: 8,
    shadowColor: const Color(0x40000000),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF818CF8),
          fontSize: 12,
        );
      }
      return const TextStyle(
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
        fontSize: 12,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: Color(0xFF818CF8));
      }
      return const IconThemeData(color: Color(0xFF94A3B8));
    }),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1A1A26)),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E2C),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _seedColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: const Color(0x554F46E5),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C3E),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF3F3F5A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _seedColor, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
    ),
  ),
);
