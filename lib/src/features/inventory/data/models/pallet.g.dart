// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pallet _$PalletFromJson(Map<String, dynamic> json) => _Pallet(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  name: json['name'] as String,
  supplier: json['supplier'] as String?,
  type: json['type'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$PalletToJson(_Pallet instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'name': instance.name,
  'supplier': instance.supplier,
  'type': instance.type,
  'created_at': instance.createdAt.toIso8601String(),
};
