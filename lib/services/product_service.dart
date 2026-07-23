import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Product>> fetchProducts({int limit = 10, int skip = 0}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    final data = await _getJson(uri, 'Không thể tải danh sách sản phẩm');
    return _parseProducts(data);
  }

  Future<List<Product>> fetchProductsByCategory(String slug) async {
    final uri = Uri.parse('$_baseUrl/products/category/$slug');
    final data = await _getJson(uri, 'Không thể tải sản phẩm theo danh mục');
    return _parseProducts(data);
  }

  Future<List<Product>> searchProducts(String keyword) async {
    try {
      final query = keyword.trim().toLowerCase();
      if (query.isEmpty) return [];

      // 1. Nếu có endpoint, tìm kiếm theo API trước
      final encodedKeyword = Uri.encodeQueryComponent(keyword.trim());
      final searchUri = Uri.parse(
        '$_baseUrl/products/search?q=$encodedKeyword',
      );
      final searchData = await _getJson(
        searchUri,
        'Không thể tìm kiếm sản phẩm qua API',
      );
      List<Product> apiProducts = _parseProducts(searchData);

      // Nếu API trả về kết quả thì dùng luôn
      if (apiProducts.isNotEmpty) {
        return apiProducts;
      }

      // 2. Nếu không (API không hỗ trợ tìm category/brand hoặc trả về rỗng),
      // load danh sách sản phẩm rồi filter local
      List<Product> allProducts = await fetchProducts(limit: 0);

      return allProducts.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query) ||
            p.brand.toLowerCase().contains(query);
      }).toList();
    } catch (e) {
      // Bắt try/catch rõ ràng
      throw Exception('Lỗi khi tìm kiếm sản phẩm: $e');
    }
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final data = await _getJson(uri, 'Không thể tải chi tiết sản phẩm');
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }
    throw Exception('Dữ liệu chi tiết sản phẩm không hợp lệ');
  }

  Future<dynamic> _getJson(Uri uri, String message) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('$message (${response.statusCode})');
    } catch (error) {
      if (error is Exception) {
        throw Exception('$message: ${error.toString()}');
      }
      throw Exception(message);
    }
  }

  List<Product> _parseProducts(dynamic data) {
    if (data is! Map<String, dynamic> || data['products'] is! List) {
      throw Exception('Dữ liệu sản phẩm không hợp lệ');
    }

    return (data['products'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
