import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
} 