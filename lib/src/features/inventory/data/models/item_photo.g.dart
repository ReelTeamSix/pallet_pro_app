// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemPhoto _$ItemPhotoFromJson(Map<String, dynamic> json) => _ItemPhoto(
  id: (json['id'] as num).toInt(),
  userId: json['user_id'] as String,
  itemId: (json['item_id'] as num).toInt(),
  storagePath: json['storage_path'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ItemPhotoToJson(_ItemPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'item_id': instance.itemId,
      'storage_path': instance.storagePath,
      'created_at': instance.createdAt.toIso8601String(),
    };
