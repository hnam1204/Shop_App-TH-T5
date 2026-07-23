import '../core/database/database_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SqliteCategory {
  final int? id;
  final String name;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SqliteCategory({
    this.id,
    required this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory SqliteCategory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return SqliteCategory(
      id: (data['id'] as num?)?.toInt() ?? int.tryParse(document.id),
      name: data['name']?.toString() ?? '',
      image: data['image']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory SqliteCategory.fromMap(Map<String, Object?> map) {
    return SqliteCategory(
      id: map[DatabaseConstants.id] as int?,
      name: map[DatabaseConstants.name]?.toString() ?? '',
      image: map[DatabaseConstants.image]?.toString(),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, Object?> toMap() => {DatabaseConstants.id: id, ...toInsertMap()};

  Map<String, Object?> toInsertMap() => {
    DatabaseConstants.name: name,
    DatabaseConstants.image: image,
  };

  Map<String, dynamic> toFirestore({bool isCreate = false}) => {
    'id': id,
    'name': name.trim(),
    'normalizedName': name.trim().toLowerCase(),
    'image': image,
    if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  SqliteCategory copyWith({
    int? id,
    String? name,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SqliteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '');
  }
}
