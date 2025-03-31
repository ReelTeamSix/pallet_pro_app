import 'package:freezed_annotation/freezed_annotation.dart';

part 'pallet.freezed.dart';
part 'pallet.g.dart';

@freezed
class Pallet with _$Pallet {
  const factory Pallet({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? supplier,
    String? type, // e.g., 'wood', 'plastic', 'custom'
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Pallet;

  factory Pallet.fromJson(Map<String, dynamic> json) => _$PalletFromJson(json);
} 