import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required int id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'pallet_id') required int palletId,
    required String name,
    @JsonKey(name: 'product_code') String? productCode,
    @JsonKey(name: 'purchase_price') required double purchasePrice,
    @JsonKey(name: 'sale_price') double? salePrice,
    required int quantity,
    @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
    @JsonKey(name: 'expiry_date') DateTime? expiryDate,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
} 