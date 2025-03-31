// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  palletId: (json['pallet_id'] as num).toInt(),
  name: json['name'] as String,
  productCode: json['product_code'] as String?,
  purchasePrice: (json['purchase_price'] as num).toDouble(),
  salePrice: (json['sale_price'] as num?)?.toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  purchaseDate:
      json['purchase_date'] == null
          ? null
          : DateTime.parse(json['purchase_date'] as String),
  expiryDate:
      json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'pallet_id': instance.palletId,
  'name': instance.name,
  'product_code': instance.productCode,
  'purchase_price': instance.purchasePrice,
  'sale_price': instance.salePrice,
  'quantity': instance.quantity,
  'purchase_date': instance.purchaseDate?.toIso8601String(),
  'expiry_date': instance.expiryDate?.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
