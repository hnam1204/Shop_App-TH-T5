import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/login_history_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  LocalStorageService._();

  static const String _currentUserKey = 'current_user';
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _loginStateKey = 'is_logged_in';
  static const String _appSettingsKey = 'app_settings';
  static const String _loginHistoryKey = 'login_history';

  static Future<void> saveRememberLogin(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, rememberMe);
      if (rememberMe) {
        await Future.wait([
          prefs.setString(_savedEmailKey, email),
          prefs.remove(_savedPasswordKey),
        ]);
      } else {
        await clearRememberLogin();
      }
    } catch (_) {
      throw Exception('Không thể lưu thông tin Remember Me');
    }
  }

  static Future<RememberLoginData> loadRememberLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return RememberLoginData(
        rememberMe: prefs.getBool(_rememberMeKey) ?? false,
        email: prefs.getString(_savedEmailKey) ?? '',
        password: '',
      );
    } catch (_) {
      return const RememberLoginData();
    }
  }

  static Future<void> clearRememberLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_rememberMeKey, false),
        prefs.remove(_savedEmailKey),
        prefs.remove(_savedPasswordKey),
      ]);
    } catch (_) {
      throw Exception('Không thể xóa thông tin Remember Me');
    }
  }

  static Future<void> saveLoginStatus(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_loginStateKey, value);
    } catch (_) {
      throw Exception('Không thể lưu trạng thái đăng nhập');
    }
  }

  static Future<bool> getLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_loginStateKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveCurrentUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } catch (_) {
      throw Exception('Không thể lưu thông tin người dùng');
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      if (userJson == null || userJson.isEmpty) {
        return null;
      }

      final decoded = jsonDecode(userJson);
      if (decoded is Map<String, dynamic>) {
        return UserModel.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateCurrentUser(UserModel user) async {
    await saveCurrentUser(user);
    final rememberLogin = await loadRememberLogin();
    if (rememberLogin.rememberMe) {
      await saveRememberLogin(user.email, '', true);
    }
  }

  static Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appSettingsKey, jsonEncode(settings.toJson()));
    } catch (_) {
      throw Exception('Không thể lưu cài đặt ứng dụng');
    }
  }

  static Future<AppSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_appSettingsKey);
      if (settingsJson == null || settingsJson.isEmpty) {
        return const AppSettings();
      }

      final decoded = jsonDecode(settingsJson);
      if (decoded is Map<String, dynamic>) {
        return AppSettings.fromJson(decoded);
      }
      return const AppSettings();
    } catch (_) {
      return const AppSettings();
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {
      throw Exception('Không thể xóa dữ liệu cục bộ');
    }
  }

  static Future<void> logout() async {
    await saveLoginStatus(false);
  }

  static Future<List<LoginHistoryModel>> getLoginHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_loginHistoryKey);
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(historyJson);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(LoginHistoryModel.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addLoginHistory(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getLoginHistory();
      final newHistory = LoginHistoryModel(
        email: email,
        loginTime: _formatLoginTime(DateTime.now()),
        title: 'Login ${history.length + 1}',
      );

      history.insert(0, newHistory);
      await prefs.setString(
        _loginHistoryKey,
        jsonEncode(history.map((item) => item.toJson()).toList()),
      );
    } catch (_) {
      throw Exception('Không thể lưu lịch sử đăng nhập');
    }
  }

  static Future<void> clearLoginHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loginHistoryKey);
    } catch (_) {
      throw Exception('Không thể xóa lịch sử đăng nhập');
    }
  }

  static Future<void> deleteLoginHistoryAt(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getLoginHistory();
      if (index < 0 || index >= history.length) return;

      history.removeAt(index);
      await prefs.setString(
        _loginHistoryKey,
        jsonEncode(history.map((item) => item.toJson()).toList()),
      );
    } catch (_) {
      throw Exception('Không thể xóa mục lịch sử đăng nhập');
    }
  }

  static Future<void> saveUser(UserModel user) => saveCurrentUser(user);

  static Future<UserModel?> getUser() => getCurrentUser();

  static Future<void> saveRememberMe(bool value) async {
    final rememberLogin = await loadRememberLogin();
    await saveRememberLogin(rememberLogin.email, '', value);
  }

  static Future<bool> getRememberMe() async {
    final data = await loadRememberLogin();
    return data.rememberMe;
  }

  static Future<void> saveLoginState(bool value) => saveLoginStatus(value);

  static Future<bool> getLoginState() => getLoginStatus();

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final settings = await getSettings();
    await saveSettings(
      settings.copyWith(
        isDarkMode: mode == ThemeMode.dark,
        themeMode: mode.name,
      ),
    );
  }

  static Future<ThemeMode> getThemeMode() async {
    final settings = await getSettings();
    return switch (settings.themeMode) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  static String _formatLoginTime(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    String threeDigits(int value) => value.toString().padLeft(3, '0');

    return '${time.year}-'
        '${twoDigits(time.month)}-'
        '${twoDigits(time.day)} '
        '${twoDigits(time.hour)}:'
        '${twoDigits(time.minute)}:'
        '${twoDigits(time.second)}.'
        '${threeDigits(time.millisecond)}';
  }
}

class RememberLoginData {
  final String email;
  final String password;
  final bool rememberMe;

  const RememberLoginData({
    this.email = '',
    this.password = '',
    this.rememberMe = false,
  });
}
