import 'package:flutter/foundation.dart';

import '../constants/app_assets.dart';

class AppConfig {
  AppConfig._();

  static const String imageProxyUrl = '';

  static const List<String> allowedImageDomains = [
    'firebasestorage.googleapis.com',
    'firebasestorage.app',
    'dummyjson.com',
    'cdn.dummyjson.com',
    '24hstore.vn',
  ];

  static const String defaultPlaceholderImage = AppAssets.banner1;
}

String getSafeImageUrl(String url) {
  final value = url.trim();
  if (value.isEmpty || !kIsWeb || AppConfig.imageProxyUrl.isEmpty) {
    return value;
  }

  final uri = Uri.tryParse(value);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return value;
  }

  final isAllowed = AppConfig.allowedImageDomains.any(
    (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
  );

  if (isAllowed) return value;

  return '${AppConfig.imageProxyUrl}?url=${Uri.encodeComponent(value)}';
}
