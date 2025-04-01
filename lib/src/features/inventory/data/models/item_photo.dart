import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'item_photo.freezed.dart';
part 'item_photo.g.dart';

@freezed
class ItemPhoto with _$ItemPhoto {
  const factory ItemPhoto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'image_url') required String imageUrl, // Or imagePath if storing path only
    String? description,
    @Default(false) @JsonKey(name: 'is_primary') bool isPrimary,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ItemPhoto;

  factory ItemPhoto.fromJson(Map<String, dynamic> json) => _$ItemPhotoFromJson(json);
} 