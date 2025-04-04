// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pallet _$PalletFromJson(Map<String, dynamic> json) => _Pallet(
  id: json['id'] as String,
  name: json['name'] as String,
  cost: (json['cost'] as num).toDouble(),
  type: json['type'] as String?,
  supplier: json['supplier'] as String?,
  purchaseDate:
      json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PalletToJson(_Pallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cost': instance.cost,
  'type': instance.type,
  'supplier': instance.supplier,
  'purchase_date': instance.purchaseDate?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
