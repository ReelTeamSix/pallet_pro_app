// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemPhoto {

 int get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'item_id') int get itemId;@JsonKey(name: 'storage_path') String get storagePath;// e.g., path in cloud storage
@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemPhotoCopyWith<ItemPhoto> get copyWith => _$ItemPhotoCopyWithImpl<ItemPhoto>(this as ItemPhoto, _$identity);

  /// Serializes this ItemPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,itemId,storagePath,createdAt);

@override
String toString() {
  return 'ItemPhoto(id: $id, userId: $userId, itemId: $itemId, storagePath: $storagePath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ItemPhotoCopyWith<$Res>  {
  factory $ItemPhotoCopyWith(ItemPhoto value, $Res Function(ItemPhoto) _then) = _$ItemPhotoCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'item_id') int itemId,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$ItemPhotoCopyWithImpl<$Res>
    implements $ItemPhotoCopyWith<$Res> {
  _$ItemPhotoCopyWithImpl(this._self, this._then);

  final ItemPhoto _self;
  final $Res Function(ItemPhoto) _then;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? itemId = null,Object? storagePath = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ItemPhoto implements ItemPhoto {
  const _ItemPhoto({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'storage_path') required this.storagePath, @JsonKey(name: 'created_at') required this.createdAt});
  factory _ItemPhoto.fromJson(Map<String, dynamic> json) => _$ItemPhotoFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'item_id') final  int itemId;
@override@JsonKey(name: 'storage_path') final  String storagePath;
// e.g., path in cloud storage
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemPhotoCopyWith<_ItemPhoto> get copyWith => __$ItemPhotoCopyWithImpl<_ItemPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,itemId,storagePath,createdAt);

@override
String toString() {
  return 'ItemPhoto(id: $id, userId: $userId, itemId: $itemId, storagePath: $storagePath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ItemPhotoCopyWith<$Res> implements $ItemPhotoCopyWith<$Res> {
  factory _$ItemPhotoCopyWith(_ItemPhoto value, $Res Function(_ItemPhoto) _then) = __$ItemPhotoCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'item_id') int itemId,@JsonKey(name: 'storage_path') String storagePath,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$ItemPhotoCopyWithImpl<$Res>
    implements _$ItemPhotoCopyWith<$Res> {
  __$ItemPhotoCopyWithImpl(this._self, this._then);

  final _ItemPhoto _self;
  final $Res Function(_ItemPhoto) _then;

/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? itemId = null,Object? storagePath = null,Object? createdAt = null,}) {
  return _then(_ItemPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
