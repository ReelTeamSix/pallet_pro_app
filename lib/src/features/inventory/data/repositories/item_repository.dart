import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';
// Import custom exception/result types if defined

/// Abstract interface for managing Item data.
abstract class ItemRepository {
  /// Creates a new item.
  Future<Item> createItem(Item item);

  /// Fetches an item by its ID.
  Future<Item?> getItemById(String id);

  /// Fetches all items (potentially with pagination/filtering).
  Future<List<Item>> getAllItems();

  /// Fetches all items belonging to a specific pallet.
  Future<List<Item>> getItemsByPallet(String palletId);

  /// Fetches items based on their status.
  Future<List<Item>> getItemsByStatus(ItemStatus status);

  /// Fetches items that are considered 'stale' based on criteria (e.g., acquired date).
  Future<List<Item>> getStaleItems({required Duration staleThreshold});

  /// Updates an existing item.
  Future<Item> updateItem(Item item);

  /// Deletes an item by its ID.
  Future<void> deleteItem(String id);

  // Add other specific methods like search, batch updates, etc.
  // Future<double> calculateItemProfit(String itemId); // Example for business logic
} 