import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_product_snapshot.dart';
import '../constants/app_hive_constants.dart';

class FavouriteHiveService {
  Box<dynamic> get _box => Hive.box(AppHiveConstants.favouritesBox);

  List<AppProductSnapshot> getAll() {
    if (_box.isEmpty) return List<AppProductSnapshot>.empty();
    return _box.values
        .whereType<Map>()
        .map(AppProductSnapshot.fromMap)
        .toList(growable: false);
  }

  Future<void> save(AppProductSnapshot product) =>
      _box.put(product.compositeKey, product.toMap());

  Future<void> remove(String compositeKey) => _box.delete(compositeKey);

  Future<void> clear() => _box.clear();
}
