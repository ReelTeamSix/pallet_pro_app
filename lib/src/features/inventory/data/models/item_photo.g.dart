// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemPhoto _$ItemPhotoFromJson(Map<String, dynamic> json) => _ItemPhoto(
  id: json['id'] as String,
  itemId: json['item_id'] as String,
  imageUrl: json['image_url'] as String,
  description: json['description'] as String?,
  isPrimary: json['is_primary'] as bool? ?? false,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ItemPhotoToJson(_ItemPhoto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
