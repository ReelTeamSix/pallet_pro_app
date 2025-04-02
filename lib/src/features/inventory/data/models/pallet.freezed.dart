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
mixin _$Pallet implements DiagnosticableTreeMixin {

 String get id; String get name;@JsonKey(name: 'purchase_cost') double get cost; String? get type; String? get supplier; String? get source;@JsonKey(name: 'purchase_date') DateTime? get purchaseDate;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Pallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PalletCopyWith<Pallet> get copyWith => _$PalletCopyWithImpl<Pallet>(this as Pallet, _$identity);

  /// Serializes this Pallet to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Pallet'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('cost', cost))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('supplier', supplier))..add(DiagnosticsProperty('source', source))..add(DiagnosticsProperty('purchaseDate', purchaseDate))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pallet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.type, type) || other.type == type)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.source, source) || other.source == source)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,type,supplier,source,purchaseDate,createdAt,updatedAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Pallet(id: $id, name: $name, cost: $cost, type: $type, supplier: $supplier, source: $source, purchaseDate: $purchaseDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PalletCopyWith<$Res>  {
  factory $PalletCopyWith(Pallet value, $Res Function(Pallet) _then) = _$PalletCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'purchase_cost') double cost, String? type, String? supplier, String? source,@JsonKey(name: 'purchase_date') DateTime? purchaseDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? type = freezed,Object? supplier = freezed,Object? source = freezed,Object? purchaseDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Pallet with DiagnosticableTreeMixin implements Pallet {
  const _Pallet({required this.id, required this.name, @JsonKey(name: 'purchase_cost') required this.cost, this.type, this.supplier, this.source, @JsonKey(name: 'purchase_date') this.purchaseDate, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Pallet.fromJson(Map<String, dynamic> json) => _$PalletFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'purchase_cost') final  double cost;
@override final  String? type;
@override final  String? supplier;
@override final  String? source;
@override@JsonKey(name: 'purchase_date') final  DateTime? purchaseDate;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

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
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'Pallet'))
    ..add(DiagnosticsProperty('id', id))..add(DiagnosticsProperty('name', name))..add(DiagnosticsProperty('cost', cost))..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('supplier', supplier))..add(DiagnosticsProperty('source', source))..add(DiagnosticsProperty('purchaseDate', purchaseDate))..add(DiagnosticsProperty('createdAt', createdAt))..add(DiagnosticsProperty('updatedAt', updatedAt));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pallet&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.type, type) || other.type == type)&&(identical(other.supplier, supplier) || other.supplier == supplier)&&(identical(other.source, source) || other.source == source)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,cost,type,supplier,source,purchaseDate,createdAt,updatedAt);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'Pallet(id: $id, name: $name, cost: $cost, type: $type, supplier: $supplier, source: $source, purchaseDate: $purchaseDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PalletCopyWith<$Res> implements $PalletCopyWith<$Res> {
  factory _$PalletCopyWith(_Pallet value, $Res Function(_Pallet) _then) = __$PalletCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'purchase_cost') double cost, String? type, String? supplier, String? source,@JsonKey(name: 'purchase_date') DateTime? purchaseDate,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cost = null,Object? type = freezed,Object? supplier = freezed,Object? source = freezed,Object? purchaseDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Pallet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,supplier: freezed == supplier ? _self.supplier : supplier // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
