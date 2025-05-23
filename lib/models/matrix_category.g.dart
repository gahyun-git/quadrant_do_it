// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matrix_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatrixCategoryImpl _$$MatrixCategoryImplFromJson(Map<String, dynamic> json) =>
    _$MatrixCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MatrixCategoryImplToJson(
  _$MatrixCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
};
