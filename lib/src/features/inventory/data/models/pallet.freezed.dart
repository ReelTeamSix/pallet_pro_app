// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pallet {

 String get id;@JsonKey(name: 'user_id') String get userId; String? get name; String? get supplier; String? get type;// Consider using an enum later
@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of Pallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PalletCopyWith<Pallet> get copyWith => _$PalletCopyWithImpl<Pallet>(this as Pallet, _$identity);

  /// Serializes this Pallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pallet&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,supplier,type,createdAt);

@override
String toString() {
  return 'Pallet(id: $id, userId: $userId, name: $name, supplier: $supplier, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PalletCopyWith<$Res>  {
  factory $PalletCopyWith(Pallet value, $Res Function(Pallet) _then) = _$PalletCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? name, String? supplier, String? type,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$PalletCopyWithImpl<$Res>
    implements $PalletCopyWith<$Res> {
  _$PalletCopyWithImpl(this._self, this._then);

  final Pallet _self;
  final $Res Function(Pallet) _then;

/// Create a copy of Pallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = freezed,Object? supplier = freezed,Object? type = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Pallet implements Pallet {
  const _Pallet({required this.id, @JsonKey(name: 'user_id') required this.userId, this.name, this.supplier, this.type, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Pallet.fromJson(Map<String, dynamic> json) => _$PalletFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String? name;
@override final  String? supplier;
@override final  String? type;
// Consider using an enum later
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of Pallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PalletCopyWith<_Pallet> get copyWith => __$PalletCopyWithImpl<_Pallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PalletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pallet&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.type, type) || other.type == type)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,supplier,type,createdAt);

@override
String toString() {
  return 'Pallet(id: $id, userId: $userId, name: $name, supplier: $supplier, type: $type, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PalletCopyWith<$Res> implements $PalletCopyWith<$Res> {
  factory _$PalletCopyWith(_Pallet value, $Res Function(_Pallet) _then) = __$PalletCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String? name, String? supplier, String? type,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$PalletCopyWithImpl<$Res>
    implements _$PalletCopyWith<$Res> {
  __$PalletCopyWithImpl(this._self, this._then);

  final _Pallet _self;
  final $Res Function(_Pallet) _then;

/// Create a copy of Pallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = freezed,Object? supplier = freezed,Object? type = freezed,Object? createdAt = null,}) {
  return _then(_Pallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
