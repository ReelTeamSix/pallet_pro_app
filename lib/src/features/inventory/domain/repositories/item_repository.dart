import 'package:pallet_pro_app/src/features/inventory/data/models/item.dart';

/// Repository interface for item operations.
abstract class ItemRepository {
  /// Fetches all items belonging to a specific pallet.
  Future<List<Item>> fetchItemsByPallet(int palletId);

  /// Fetches a single item by its ID.
  Future<Item?> fetchItemById(int itemId);

  /// Creates a new item.
  /// [item] contains the data for the new item (excluding id, user_id, created_at, updated_at).
  Future<Item> createItem(Item item);

  /// Updates an existing item.
  /// Handles setting the `updated_at` timestamp.
  Future<Item> updateItem(Item item);

  /// Deletes an item by its ID.
  Future<void> deleteItem(int itemId);

  // TODO: Consider adding search/filter methods if needed later
  // Future<List<Item>> searchItems(String query);
} 