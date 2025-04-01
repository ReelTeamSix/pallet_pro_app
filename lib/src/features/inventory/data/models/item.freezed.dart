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
mixin _$Item implements DiagnosticableTreeMixin {

 String get id;@JsonKey(name: 'pallet_id') String get palletId; String get name; String? get description; int get quantity;// Default to 1 if not specified
@JsonKey(name: 'purchase_price') double? get purchasePrice;// May be calculated/allocated later
@JsonKey(name: 'sale_price') double? get salePrice; String? get sku; ItemCondition get condition; ItemStatus get status;@JsonKey(name: 'acquired_date') DateTime? get acquiredDate;// Often same as pallet purchase date
@JsonKey(name: 'sold_date') DateTime? get soldDate;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;// Placeholder for relationships - we might adjust how these are stored/fetched later
// List<ItemPhoto>? photos,
// List<Tag>? tags,
// Field to store the allocated cost per item from the pallet cost
@JsonKey(name: 'allocated_cost') double? get allocatedCost;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Item'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('palletId', palletId))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('quantity', quantity))..add(DiagnosticsProperty('purchasePrice', purchasePrice))..add(DiagnosticsProperty('salePrice', salePrice))..add(DiagnosticsProperty('sku', sku))..add(DiagnosticsProperty('condition', condition))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('acquiredDate', acquiredDate))..add(DiagnosticsProperty('soldDate', soldDate))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('allocatedCost', allocatedCost));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.palletId, palletId) || other.palletId == palletId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.soldDate, soldDate) || other.soldDate == soldDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.allocatedCost, allocatedCost) || other.allocatedCost == allocatedCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,palletId,name,description,quantity,purchasePrice,salePrice,sku,condition,status,acquiredDate,soldDate,createdAt,updatedAt,allocatedCost);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Item(id: $id, palletId: $palletId, name: $name, description: $description, quantity: $quantity, purchasePrice: $purchasePrice, salePrice: $salePrice, sku: $sku, condition: $condition, status: $status, acquiredDate: $acquiredDate, soldDate: $soldDate, createdAt: $createdAt, updatedAt: $updatedAt, allocatedCost: $allocatedCost)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'pallet_id') String palletId, String name, String? description, int quantity,@JsonKey(name: 'purchase_price') double? purchasePrice,@JsonKey(name: 'sale_price') double? salePrice, String? sku, ItemCondition condition, ItemStatus status,@JsonKey(name: 'acquired_date') DateTime? acquiredDate,@JsonKey(name: 'sold_date') DateTime? soldDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'allocated_cost') double? allocatedCost
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? palletId = null,Object? name = null,Object? description = freezed,Object? quantity = null,Object? purchasePrice = freezed,Object? salePrice = freezed,Object? sku = freezed,Object? condition = null,Object? status = null,Object? acquiredDate = freezed,Object? soldDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? allocatedCost = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,palletId: null == palletId ? _self.palletId : palletId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double?,salePrice: freezed == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,acquiredDate: freezed == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,soldDate: freezed == soldDate ? _self.soldDate : soldDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allocatedCost: freezed == allocatedCost ? _self.allocatedCost : allocatedCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Item with DiagnosticableTreeMixin implements Item {
  const _Item({required this.id, @JsonKey(name: 'pallet_id') required this.palletId, required this.name, this.description, required this.quantity = 1, @JsonKey(name: 'purchase_price') this.purchasePrice, @JsonKey(name: 'sale_price') this.salePrice, this.sku, required this.condition = ItemCondition.newItem, required this.status = ItemStatus.forSale, @JsonKey(name: 'acquired_date') this.acquiredDate, @JsonKey(name: 'sold_date') this.soldDate, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'allocated_cost') this.allocatedCost});
  factory _Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'pallet_id') final  String palletId;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int quantity;
// Default to 1 if not specified
@override@JsonKey(name: 'purchase_price') final  double? purchasePrice;
// May be calculated/allocated later
@override@JsonKey(name: 'sale_price') final  double? salePrice;
@override final  String? sku;
@override@JsonKey() final  ItemCondition condition;
@override@JsonKey() final  ItemStatus status;
@override@JsonKey(name: 'acquired_date') final  DateTime? acquiredDate;
// Often same as pallet purchase date
@override@JsonKey(name: 'sold_date') final  DateTime? soldDate;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
// Placeholder for relationships - we might adjust how these are stored/fetched later
// List<ItemPhoto>? photos,
// List<Tag>? tags,
// Field to store the allocated cost per item from the pallet cost
@override@JsonKey(name: 'allocated_cost') final  double? allocatedCost;

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
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Item'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('palletId', palletId))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('description', description))..add(DiagnosticsProperty('quantity', quantity))..add(DiagnosticsProperty('purchasePrice', purchasePrice))..add(DiagnosticsProperty('salePrice', salePrice))..add(DiagnosticsProperty('sku', sku))..add(DiagnosticsProperty('condition', condition))..add(DiagnosticsProperty('status', status))..add(DiagnosticsProperty('acquiredDate', acquiredDate))..add(DiagnosticsProperty('soldDate', soldDate))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt))..add(DiagnosticsProperty('allocatedCost', allocatedCost));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.palletId, palletId) || other.palletId == palletId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchasePrice, purchasePrice) || other.purchasePrice == purchasePrice)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.acquiredDate, acquiredDate) || other.acquiredDate == acquiredDate)&&(identical(other.soldDate, soldDate) || other.soldDate == soldDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.allocatedCost, allocatedCost) || other.allocatedCost == allocatedCost));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,palletId,name,description,quantity,purchasePrice,salePrice,sku,condition,status,acquiredDate,soldDate,createdAt,updatedAt,allocatedCost);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Item(id: $id, palletId: $palletId, name: $name, description: $description, quantity: $quantity, purchasePrice: $purchasePrice, salePrice: $salePrice, sku: $sku, condition: $condition, status: $status, acquiredDate: $acquiredDate, soldDate: $soldDate, createdAt: $createdAt, updatedAt: $updatedAt, allocatedCost: $allocatedCost)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'pallet_id') String palletId, String name, String? description, int quantity,@JsonKey(name: 'purchase_price') double? purchasePrice,@JsonKey(name: 'sale_price') double? salePrice, String? sku, ItemCondition condition, ItemStatus status,@JsonKey(name: 'acquired_date') DateTime? acquiredDate,@JsonKey(name: 'sold_date') DateTime? soldDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'allocated_cost') double? allocatedCost
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? palletId = null,Object? name = null,Object? description = freezed,Object? quantity = null,Object? purchasePrice = freezed,Object? salePrice = freezed,Object? sku = freezed,Object? condition = null,Object? status = null,Object? acquiredDate = freezed,Object? soldDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? allocatedCost = freezed,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,palletId: null == palletId ? _self.palletId : palletId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchasePrice: freezed == purchasePrice ? _self.purchasePrice : purchasePrice // ignore: cast_nullable_to_non_nullable
as double?,salePrice: freezed == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as double?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ItemCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,acquiredDate: freezed == acquiredDate ? _self.acquiredDate : acquiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,soldDate: freezed == soldDate ? _self.soldDate : soldDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,allocatedCost: freezed == allocatedCost ? _self.allocatedCost : allocatedCost // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
