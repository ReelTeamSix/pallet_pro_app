import 'package:pallet_pro_app/src/core/utils/result.dart';
import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
// Import custom exception/result types if defined

/// Abstract interface for managing Item data.
abstract class ItemRepository {
  /// Creates a new item.
  Future<Result<Item>> createItem(Item item);

  /// Fetches an item by its ID.
  Future<Result<Item?>> getItemById(String id);

  /// Fetches all items, potentially filtered.
  Future<Result<List<Item>>> getAllItems({
    ItemStatus? statusFilter,
    String? storageLocationFilter,
    String? salesChannelFilter,
    String? palletSourceFilter, // Filter by source field in the related pallet
  });

  /// Fetches all items belonging to a specific pallet.
  Future<Result<List<Item>>> getItemsByPallet(String palletId);

  /// Fetches items based on their status.
  /// Deprecated: Use getAllItems with statusFilter instead.
  @Deprecated('Use getAllItems with statusFilter instead')
  Future<Result<List<Item>>> getItemsByStatus(ItemStatus status);

  /// Fetches items that are considered 'stale' based on criteria (e.g., acquired date).
  Future<Result<List<Item>>> getStaleItems({required Duration staleThreshold});

  /// Updates an existing item.
  Future<Result<Item>> updateItem(Item item);

  /// Deletes an item by its ID.
  Future<Result<void>> deleteItem(String id);

  // Add other specific methods like search, batch updates, etc.
  // Future<double> calculateItemProfit(String itemId); // Example for business logic
} 