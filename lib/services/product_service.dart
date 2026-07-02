import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com';

  Future<List<Product>> fetchProducts({int limit = 10, int skip = 0}) async {
    final uri = Uri.parse('$_baseUrl/products?limit=$limit&skip=$skip');
    final data = await _getJson(uri, 'Khong the tai danh sach san pham');
    return _parseProducts(data);
  }

  Future<List<Product>> fetchProductsByCategory(String slug) async {
    final uri = Uri.parse('$_baseUrl/products/category/$slug');
    final data = await _getJson(uri, 'Khong the tai san pham theo danh muc');
    return _parseProducts(data);
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword.trim());
    final uri = Uri.parse('$_baseUrl/products/search?q=$encodedKeyword');
    final data = await _getJson(uri, 'Khong the tim kiem san pham');
    return _parseProducts(data);
  }

  Future<Product> fetchProductDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final data = await _getJson(uri, 'Khong the tai chi tiet san pham');
    if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    }
    throw Exception('Du lieu chi tiet san pham khong hop le');
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
      throw Exception('Du lieu san pham khong hop le');
    }

    return (data['products'] as List)
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
