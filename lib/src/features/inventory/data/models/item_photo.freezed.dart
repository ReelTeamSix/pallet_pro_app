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
mixin _$ItemPhoto implements DiagnosticableTreeMixin {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'image_url') String get imageUrl;// Or imagePath if storing path only
 String? get description;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of ItemPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemPhotoCopyWith<ItemPhoto> get copyWith => _$ItemPhotoCopyWithImpl<ItemPhoto>(this as ItemPhoto, _$identity);

  /// Serializes this ItemPhoto to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ItemPhoto'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('itemId', itemId))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('isPrimary', isPrimary))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,imageUrl,description,isPrimary,createdAt,updatedAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ItemPhoto(id: $id, itemId: $itemId, imageUrl: $imageUrl, description: $description, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemPhotoCopyWith<$Res>  {
  factory $ItemPhotoCopyWith(ItemPhoto value, $Res Function(ItemPhoto) _then) = _$ItemPhotoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'image_url') String imageUrl, String? description,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? imageUrl = null,Object? description = freezed,Object? isPrimary = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _ItemPhoto with DiagnosticableTreeMixin implements ItemPhoto {
  const _ItemPhoto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'image_url') required this.imageUrl, this.description, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ItemPhoto.fromJson(Map<String, dynamic> json) => _$ItemPhotoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'image_url') final  String imageUrl;
// Or imagePath if storing path only
@override final  String? description;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

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
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ItemPhoto'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('itemId', itemId))..add(DiagnosticsProperty('imageUrl', imageUrl))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('isPrimary', isPrimary))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,imageUrl,description,isPrimary,createdAt,updatedAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ItemPhoto(id: $id, itemId: $itemId, imageUrl: $imageUrl, description: $description, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemPhotoCopyWith<$Res> implements $ItemPhotoCopyWith<$Res> {
  factory _$ItemPhotoCopyWith(_ItemPhoto value, $Res Function(_ItemPhoto) _then) = __$ItemPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'image_url') String imageUrl, String? description,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? imageUrl = null,Object? description = freezed,Object? isPrimary = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ItemPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
