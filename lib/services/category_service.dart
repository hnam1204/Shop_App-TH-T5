import 'dart:convert';

import 'package:flutter/services.dart';

import '../constants/app_assets.dart';
import '../models/category.dart';

class CategoryService {
  Future<List<Category>> loadCategories() async {
    try {
      final data = await rootBundle.loadString(AppAssets.categoriesJson);
      final decoded = jsonDecode(data);
      if (decoded is! List) {
        throw const FormatException('Invalid categories format');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    } catch (_) {
      throw Exception('Không thể tải danh mục sản phẩm');
    }
  }
}
