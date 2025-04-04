import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

// Assuming item_photo.dart and tag.dart will be created later
// import 'item_photo.dart';
// import 'tag.dart';

part 'item.freezed.dart';
part 'item.g.dart';

enum ItemCondition {
  newItem,
  openBox,
  usedGood,
  usedFair,
  damaged,
  forParts,
}

enum ItemStatus {
  @JsonValue('in_stock')
  inStock,
  @JsonValue('for_sale')
  forSale,
  @JsonValue('listed')
  listed,
  @JsonValue('sold')
  sold,
}

@freezed
abstract class Item with _$Item {
  const factory Item({
    required String id,
    @JsonKey(name: 'pallet_id') required String palletId,
    required String name,
    String? description,
    @Default(1) int quantity, // Removed 'required' keyword
    @JsonKey(name: 'purchase_price') double? purchasePrice, // May be calculated/allocated later
    @JsonKey(name: 'sale_price') double? salePrice,
    @JsonKey(name: 'listing_price') double? listingPrice,
    @JsonKey(name: 'listing_platform') String? listingPlatform,
    @JsonKey(name: 'listing_date') DateTime? listingDate,
    @JsonKey(name: 'selling_platform') String? sellingPlatform,
    @JsonKey(name: 'sold_price') double? soldPrice, // Added field for sold price
    String? sku,
    @Default(ItemCondition.newItem) ItemCondition condition, // Removed 'required' keyword
    @Default(ItemStatus.inStock) ItemStatus status, // Updated default status to inStock
    @JsonKey(name: 'storage_location') String? storageLocation, // Added field
    @JsonKey(name: 'sales_channel') String? salesChannel, // Added field
    @JsonKey(name: 'acquired_date') DateTime? acquiredDate, // Often same as pallet purchase date
    @JsonKey(name: 'sold_date') DateTime? soldDate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // Placeholder for relationships - we might adjust how these are stored/fetched later
    // List<ItemPhoto>? photos,
    // List<Tag>? tags,

    // Field to store the allocated cost per item from the pallet cost
    @JsonKey(name: 'allocated_cost') double? allocatedCost,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
} 