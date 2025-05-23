import 'package:freezed_annotation/freezed_annotation.dart';

part 'matrix_category.freezed.dart';
part 'matrix_category.g.dart';

@freezed
class MatrixCategory with _$MatrixCategory {
  const factory MatrixCategory({
    required String id,
    required String name,
    required DateTime createdAt,
  }) = _MatrixCategory;

  factory MatrixCategory.fromJson(Map<String, dynamic> json) => _$MatrixCategoryFromJson(json);
} 