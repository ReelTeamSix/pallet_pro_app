// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Item {

 int get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'pallet_id') int get palletId; String get name;@JsonKey(name: 'product_code') String? get productCode;@JsonKey(name: 'purchase_price') double get purchasePrice;@JsonKey(name: 'sale_price') double? get salePrice; int get quantity;@JsonKey(name: 'purchase_date') DateTime? get purchaseDate;@JsonKey(name: 'expiry_date') DateTime? get expiryDate; String? get notes;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.palletId, palletId) || other.palletId == palletId)&&(identical(other.name, name) || other.name == name)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,palletId,name,productCode,purchasePrice,salePrice,quantity,purchaseDate,expiryDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Item(id: $id, userId: $userId, palletId: $palletId, name: $name, productCode: $productCode, purchasePrice: $purchasePrice, salePrice: $salePrice, quantity: $quantity, purchaseDate: $purchaseDate, expiryDate: $expiryDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pallet_id') int palletId, String name,@JsonKey(name: 'product_code') String? productCode,@JsonKey(name: 'purchase_price') double purchasePrice,@JsonKey(name: 'sale_price') double? salePrice, int quantity,@JsonKey(name: 'purchase_date') DateTime? purchaseDate,@JsonKey(name: 'expiry_date') DateTime? expiryDate, String? notes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? palletId = null,Object? name = null,Object? productCode = freezed,Object? purchasePrice = null,Object? salePrice = freezed,Object? quantity = null,Object? purchaseDate = freezed,Object? expiryDate = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,palletId: null == palletId ? _self.palletId : palletId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,salePrice: freezed == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Item implements Item {
  const _Item({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'pallet_id') required this.palletId, required this.name, @JsonKey(name: 'product_code') this.productCode, @JsonKey(name: 'purchase_price') required this.purchasePrice, @JsonKey(name: 'sale_price') this.salePrice, required this.quantity, @JsonKey(name: 'purchase_date') this.purchaseDate, @JsonKey(name: 'expiry_date') this.expiryDate, this.notes, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  int id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'pallet_id') final  int palletId;
@override final  String name;
@override@JsonKey(name: 'product_code') final  String? productCode;
@override@JsonKey(name: 'purchase_price') final  double purchasePrice;
@override@JsonKey(name: 'sale_price') final  double? salePrice;
@override final  int quantity;
@override@JsonKey(name: 'purchase_date') final  DateTime? purchaseDate;
@override@JsonKey(name: 'expiry_date') final  DateTime? expiryDate;
@override final  String? notes;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.palletId, palletId) || other.palletId == palletId)&&(identical(other.name, name) || other.name == name)&&(identical(other.productCode, productCode) || other.productCode == productCode)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,palletId,name,productCode,purchasePrice,salePrice,quantity,purchaseDate,expiryDate,notes,createdAt,updatedAt);

@override
String toString() {
  return 'Item(id: $id, userId: $userId, palletId: $palletId, name: $name, productCode: $productCode, purchasePrice: $purchasePrice, salePrice: $salePrice, quantity: $quantity, purchaseDate: $purchaseDate, expiryDate: $expiryDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'pallet_id') int palletId, String name,@JsonKey(name: 'product_code') String? productCode,@JsonKey(name: 'purchase_price') double purchasePrice,@JsonKey(name: 'sale_price') double? salePrice, int quantity,@JsonKey(name: 'purchase_date') DateTime? purchaseDate,@JsonKey(name: 'expiry_date') DateTime? expiryDate, String? notes,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? palletId = null,Object? name = null,Object? productCode = freezed,Object? purchasePrice = null,Object? salePrice = freezed,Object? quantity = null,Object? purchaseDate = freezed,Object? expiryDate = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,palletId: null == palletId ? _self.palletId : palletId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,productCode: freezed == productCode ? _self.productCode : productCode // ignore: cast_nullable_to_non_nullable
as String?,purchasePrice: null == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double,salePrice: freezed == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
