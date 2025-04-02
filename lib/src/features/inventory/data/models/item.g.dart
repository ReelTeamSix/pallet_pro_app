// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Item _$ItemFromJson(Map<String, dynamic> json) => _Item(
  id: json['id'] as String,
  palletId: json['pallet_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
  salePrice: (json['sale_price'] as num?)?.toDouble(),
  sku: json['sku'] as String?,
  condition:
      $enumDecodeNullable(_$ItemConditionEnumMap, json['condition']) ??
      ItemCondition.newItem,
  status:
      $enumDecodeNullable(_$ItemStatusEnumMap, json['status']) ??
      ItemStatus.forSale,
  storageLocation: json['storage_location'] as String?,
  salesChannel: json['sales_channel'] as String?,
  acquiredDate:
      json['acquired_date'] == null
          ? null
          : DateTime.parse(json['acquired_date'] as String),
  soldDate:
      json['sold_date'] == null
          ? null
          : DateTime.parse(json['sold_date'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  allocatedCost: (json['allocated_cost'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ItemToJson(_Item instance) => <String, dynamic>{
  'id': instance.id,
  'pallet_id': instance.palletId,
  'name': instance.name,
  'description': instance.description,
  'quantity': instance.quantity,
  'purchase_price': instance.purchasePrice,
  'sale_price': instance.salePrice,
  'sku': instance.sku,
  'condition': _$ItemConditionEnumMap[instance.condition]!,
  'status': _$ItemStatusEnumMap[instance.status]!,
  'storage_location': instance.storageLocation,
  'sales_channel': instance.salesChannel,
  'acquired_date': instance.acquiredDate?.toIso8601String(),
  'sold_date': instance.soldDate?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'allocated_cost': instance.allocatedCost,
};

const _$ItemConditionEnumMap = {
  ItemCondition.newItem: 'newItem',
  ItemCondition.openBox: 'openBox',
  ItemCondition.usedGood: 'usedGood',
  ItemCondition.usedFair: 'usedFair',
  ItemCondition.damaged: 'damaged',
  ItemCondition.forParts: 'forParts',
};

const _$ItemStatusEnumMap = {
  ItemStatus.forSale: 'for_sale',
  ItemStatus.sold: 'sold',
  ItemStatus.archived: 'archived',
};
