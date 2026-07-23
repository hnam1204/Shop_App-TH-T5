import 'package:firebase_auth/firebase_auth.dart';

import '../data/firestore/week8_category_firestore_repository.dart';
import '../models/sqlite_category.dart';

class CategoryValidationException implements Exception {
  final String message;
  const CategoryValidationException(this.message);
  @override
  String toString() => message;
}

class DuplicateCategoryException extends CategoryValidationException {
  const DuplicateCategoryException() : super('Tên danh mục đã tồn tại.');
}

class CategoryHasProductsException extends CategoryValidationException {
  const CategoryHasProductsException()
    : super('Không thể xóa danh mục đang có sản phẩm.');
}

class CategoryNotFoundException extends CategoryValidationException {
  const CategoryNotFoundException() : super('Không tìm thấy danh mục.');
}

class SqliteCategoryService {
  final Week8CategoryFirestoreRepository _repository;
  final FirebaseAuth _auth;

  SqliteCategoryService({
    Week8CategoryFirestoreRepository? repository,
    FirebaseAuth? auth,
  }) : _repository = repository ?? Week8CategoryFirestoreRepository(),
       _auth = auth ?? FirebaseAuth.instance;

  Future<List<SqliteCategory>> getAllCategories() async {
    _requireUser();
    return _repository.getAllCategories();
  }

  Future<SqliteCategory> createCategory({
    required String name,
    String? image,
  }) async {
    _requireUser();
    final cleanName = _validateName(name);
    if (await _repository.categoryNameExists(cleanName)) {
      throw const DuplicateCategoryException();
    }
    final category = SqliteCategory(name: cleanName, image: _optional(image));
    final id = await _repository.insertCategory(category);
    return category.copyWith(id: id);
  }

  Future<SqliteCategory> updateCategory(SqliteCategory category) async {
    _requireUser();
    final id = category.id;
    if (id == null || await _repository.getCategoryById(id) == null) {
      throw const CategoryNotFoundException();
    }
    final cleanName = _validateName(category.name);
    if (await _repository.categoryNameExists(cleanName, excludeId: id)) {
      throw const DuplicateCategoryException();
    }
    final normalized = SqliteCategory(
      id: id,
      name: cleanName,
      image: _optional(category.image),
      createdAt: category.createdAt,
    );
    await _repository.updateCategory(normalized);
    return normalized;
  }

  Future<void> deleteCategory(int id) async {
    _requireUser();
    if (await _repository.getCategoryById(id) == null) {
      throw const CategoryNotFoundException();
    }
    if (await _repository.categoryHasProducts(id)) {
      throw const CategoryHasProductsException();
    }
    await _repository.deleteCategory(id);
  }

  void _requireUser() {
    if (_auth.currentUser == null) {
      throw const CategoryValidationException(
        'Vui lòng đăng nhập để sử dụng chức năng này.',
      );
    }
  }

  String _validateName(String name) {
    final value = name.trim();
    if (value.isEmpty) {
      throw const CategoryValidationException(
        'Tên danh mục không được để trống.',
      );
    }
    return value;
  }

  String? _optional(String? value) {
    final clean = value?.trim() ?? '';
    return clean.isEmpty ? null : clean;
  }
}
