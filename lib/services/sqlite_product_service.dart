import 'package:firebase_auth/firebase_auth.dart';

import '../data/firestore/week8_category_firestore_repository.dart';
import '../data/firestore/week8_product_firestore_repository.dart';
import '../models/sqlite_product.dart';

class ProductValidationException implements Exception {
  final String message;
  const ProductValidationException(this.message);
  @override
  String toString() => message;
}

class ProductNotFoundException extends ProductValidationException {
  const ProductNotFoundException() : super('Không tìm thấy sản phẩm.');
}

class ProductCategoryNotFoundException extends ProductValidationException {
  const ProductCategoryNotFoundException()
    : super('Danh mục đã chọn không tồn tại.');
}

class SqliteProductService {
  final Week8ProductFirestoreRepository _repository;
  final Week8CategoryFirestoreRepository _categoryRepository;
  final FirebaseAuth _auth;

  SqliteProductService({
    Week8ProductFirestoreRepository? repository,
    Week8CategoryFirestoreRepository? categoryRepository,
    FirebaseAuth? auth,
  }) : _repository = repository ?? Week8ProductFirestoreRepository(),
       _categoryRepository =
           categoryRepository ?? Week8CategoryFirestoreRepository(),
       _auth = auth ?? FirebaseAuth.instance;

  Future<List<SqliteProduct>> getAllProducts() {
    _requireUser();
    return _repository.getAllProducts();
  }

  Future<List<SqliteProduct>> getProductsByCategory(int categoryId) {
    _requireUser();
    return _repository.getProductsByCategory(categoryId);
  }

  Future<SqliteProduct> createProduct({
    required String name,
    required double price,
    String? image,
    String description = '',
    required int categoryId,
  }) async {
    _requireUser();
    final product = await _normalize(
      SqliteProduct(
        name: name,
        price: price,
        image: image,
        description: description,
        categoryId: categoryId,
      ),
    );
    final id = await _repository.insertProduct(product);
    return product.copyWith(id: id);
  }

  Future<SqliteProduct> updateProduct(SqliteProduct product) async {
    _requireUser();
    final id = product.id;
    if (id == null || await _repository.getProductById(id) == null) {
      throw const ProductNotFoundException();
    }
    final normalized = await _normalize(product);
    await _repository.updateProduct(normalized);
    return normalized;
  }

  Future<void> deleteProduct(int id) async {
    _requireUser();
    if (await _repository.getProductById(id) == null) {
      throw const ProductNotFoundException();
    }
    await _repository.deleteProduct(id);
  }

  Future<SqliteProduct> _normalize(SqliteProduct product) async {
    final name = product.name.trim();
    if (name.isEmpty) {
      throw const ProductValidationException(
        'Tên sản phẩm không được để trống.',
      );
    }
    if (!product.price.isFinite || product.price < 0) {
      throw const ProductValidationException('Giá sản phẩm không hợp lệ.');
    }
    final category = await _categoryRepository.getCategoryById(
      product.categoryId,
    );
    if (category == null) throw const ProductCategoryNotFoundException();
    return SqliteProduct(
      id: product.id,
      name: name,
      price: product.price,
      image: _optional(product.image),
      description: product.description.trim(),
      categoryId: product.categoryId,
      categoryName: category.name,
      createdAt: product.createdAt,
    );
  }

  void _requireUser() {
    if (_auth.currentUser == null) {
      throw const ProductValidationException(
        'Vui lòng đăng nhập để sử dụng chức năng này.',
      );
    }
  }

  String? _optional(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? null : clean;
  }
}
