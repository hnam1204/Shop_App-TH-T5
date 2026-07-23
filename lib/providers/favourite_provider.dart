import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_product_snapshot.dart';
import '../services/favourite_hive_service.dart';

class FavouriteState {
  final List<AppProductSnapshot> items;
  final bool isSaving;
  final String? errorMessage;

  const FavouriteState({
    this.items = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  int get totalItems => items.length;
  bool contains(String key) => items.any((item) => item.compositeKey == key);
}

class FavouriteNotifier extends AsyncNotifier<FavouriteState> {
  late final FavouriteHiveService _service;
  Future<void> _queue = Future.value();

  @override
  Future<FavouriteState> build() async {
    _service = FavouriteHiveService();
    return FavouriteState(items: _service.getAll());
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => FavouriteState(items: _service.getAll()),
    );
  }

  Future<void> add(AppProductSnapshot product) => _serialized(() async {
    if (!state.requireValue.contains(product.compositeKey)) {
      await _service.save(product);
    }
  });

  Future<void> remove(String key) => _serialized(() => _service.remove(key));

  Future<void> toggle(AppProductSnapshot product) => _serialized(() async {
    if (state.requireValue.contains(product.compositeKey)) {
      await _service.remove(product.compositeKey);
    } else {
      await _service.save(product);
    }
  });

  Future<void> clear() => _serialized(_service.clear);

  bool contains(String key) => state.value?.contains(key) ?? false;
  bool isFavourite(String key) => contains(key);

  Future<void> _serialized(Future<void> Function() operation) {
    final result = _queue.then((_) async {
      final previous = state.value ?? const FavouriteState();
      state = AsyncData(FavouriteState(items: previous.items, isSaving: true));
      try {
        await operation();
        state = AsyncData(FavouriteState(items: _service.getAll()));
      } catch (error, stackTrace) {
        state = AsyncData(
          FavouriteState(items: previous.items, errorMessage: error.toString()),
        );
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
    _queue = result.catchError((_) {});
    return result;
  }
}

final favouriteProvider =
    AsyncNotifierProvider<FavouriteNotifier, FavouriteState>(
      FavouriteNotifier.new,
    );
final favouriteItemsProvider = Provider<List<AppProductSnapshot>>(
  (ref) => ref
      .watch(favouriteProvider)
      .when(
        data: (value) => value.items,
        error: (_, _) => const [],
        loading: () => const [],
      ),
);
final favouriteCountProvider = Provider<int>(
  (ref) => ref
      .watch(favouriteProvider)
      .when(
        data: (value) => value.totalItems,
        error: (_, _) => 0,
        loading: () => 0,
      ),
);
final isFavouriteProvider = Provider.family<bool, String>(
  (ref, key) => ref
      .watch(favouriteProvider)
      .when(
        data: (value) => value.contains(key),
        error: (_, _) => false,
        loading: () => false,
      ),
);
