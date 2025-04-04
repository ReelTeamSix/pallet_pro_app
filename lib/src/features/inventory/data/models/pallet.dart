import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'pallet.freezed.dart';
part 'pallet.g.dart';

enum PalletStatus {
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('processed')
  processed,
  @JsonValue('archived')
  archived
}

@freezed
abstract class Pallet with _$Pallet {
  const factory Pallet({
    required String id,
    required String name,
    @JsonKey(name: 'purchase_cost') required double cost,
    String? type,
    String? supplier,
    String? source,
    @Default(PalletStatus.inProgress) PalletStatus status,
    @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    // Add other pallet-specific fields here
  }) = _Pallet;

  factory Pallet.fromJson(Map<String, dynamic> json) => _$PalletFromJson(json);
} 