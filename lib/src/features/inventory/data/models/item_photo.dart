import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_photo.freezed.dart';
part 'item_photo.g.dart';

@freezed
class ItemPhoto with _$ItemPhoto {
  const factory ItemPhoto({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'item_id') required int itemId,
    @JsonKey(name: 'storage_path') required String storagePath, // e.g., path in cloud storage
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ItemPhoto;

  factory ItemPhoto.fromJson(Map<String, dynamic> json) =>
      _$ItemPhotoFromJson(json);
} 