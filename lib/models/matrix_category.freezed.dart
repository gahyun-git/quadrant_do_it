// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'matrix_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatrixCategory _$MatrixCategoryFromJson(Map<String, dynamic> json) {
  return _MatrixCategory.fromJson(json);
}

/// @nodoc
mixin _$MatrixCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MatrixCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatrixCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatrixCategoryCopyWith<MatrixCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatrixCategoryCopyWith<$Res> {
  factory $MatrixCategoryCopyWith(
    MatrixCategory value,
    $Res Function(MatrixCategory) then,
  ) = _$MatrixCategoryCopyWithImpl<$Res, MatrixCategory>;
  @useResult
  $Res call({String id, String name, DateTime createdAt});
}

/// @nodoc
class _$MatrixCategoryCopyWithImpl<$Res, $Val extends MatrixCategory>
    implements $MatrixCategoryCopyWith<$Res> {
  _$MatrixCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatrixCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatrixCategoryImplCopyWith<$Res>
    implements $MatrixCategoryCopyWith<$Res> {
  factory _$$MatrixCategoryImplCopyWith(
    _$MatrixCategoryImpl value,
    $Res Function(_$MatrixCategoryImpl) then,
  ) = __$$MatrixCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, DateTime createdAt});
}

/// @nodoc
class __$$MatrixCategoryImplCopyWithImpl<$Res>
    extends _$MatrixCategoryCopyWithImpl<$Res, _$MatrixCategoryImpl>
    implements _$$MatrixCategoryImplCopyWith<$Res> {
  __$$MatrixCategoryImplCopyWithImpl(
    _$MatrixCategoryImpl _value,
    $Res Function(_$MatrixCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatrixCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MatrixCategoryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatrixCategoryImpl implements _MatrixCategory {
  const _$MatrixCategoryImpl({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory _$MatrixCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatrixCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MatrixCategory(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatrixCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt);

  /// Create a copy of MatrixCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatrixCategoryImplCopyWith<_$MatrixCategoryImpl> get copyWith =>
      __$$MatrixCategoryImplCopyWithImpl<_$MatrixCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatrixCategoryImplToJson(this);
  }
}

abstract class _MatrixCategory implements MatrixCategory {
  const factory _MatrixCategory({
    required final String id,
    required final String name,
    required final DateTime createdAt,
  }) = _$MatrixCategoryImpl;

  factory _MatrixCategory.fromJson(Map<String, dynamic> json) =
      _$MatrixCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get createdAt;

  /// Create a copy of MatrixCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatrixCategoryImplCopyWith<_$MatrixCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
